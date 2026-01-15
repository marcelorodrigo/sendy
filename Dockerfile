# Stage 1: Download and extract Sendy, install supercronic
FROM alpine:3.23.2 AS downloader
RUN apk add --no-cache curl unzip
WORKDIR /tmp

# Install supercronic for cron jobs (multi-architecture support)
ARG TARGETARCH
ENV SUPERCRONIC_VERSION=v0.2.41
RUN set -e && \
    if [ "$TARGETARCH" = "arm64" ]; then \
        SUPERCRONIC_URL="https://github.com/aptible/supercronic/releases/download/${SUPERCRONIC_VERSION}/supercronic-linux-arm64" && \
        SUPERCRONIC_SHA1SUM="44e10e33e8d98b1d1522f6719f15fb9469786ff0"; \
    else \
        SUPERCRONIC_URL="https://github.com/aptible/supercronic/releases/download/${SUPERCRONIC_VERSION}/supercronic-linux-amd64" && \
        SUPERCRONIC_SHA1SUM="f70ad28d0d739a96dc9e2087ae370c257e79b8d7"; \
    fi && \
    curl -fsSLO "$SUPERCRONIC_URL" && \
    echo "${SUPERCRONIC_SHA1SUM}  $(basename $SUPERCRONIC_URL)" | sha1sum -c - && \
    echo "Supercronic download verified."

# Download and extract Sendy using build secret
RUN --mount=type=secret,id=SENDY_LICENSE_KEY \
    set -e && \
    echo "Downloading Sendy..." && \
    if ! curl -fsSL -o sendy.zip "https://sendy.co/download/?license=$(cat /run/secrets/SENDY_LICENSE_KEY)"; then \
        echo "ERROR: Failed to download Sendy. Please verify:" >&2 && \
        echo "  - Your SENDY_LICENSE_KEY secret is correct" >&2 && \
        echo "  - You have an active Sendy license" >&2 && \
        echo "  - Network connectivity to sendy.co" >&2 && \
        exit 1; \
    fi && \
    echo "Validating download..." && \
    if ! unzip -t sendy.zip >/dev/null 2>&1; then \
        echo "ERROR: Downloaded file is not a valid ZIP archive." >&2 && \
        echo "This usually means the license key is invalid or expired." >&2 && \
        exit 1; \
    fi && \
    echo "Extracting Sendy..." && \
    unzip -q sendy.zip && \
    if [ ! -d "sendy" ]; then \
        echo "ERROR: Sendy directory not found after extraction." >&2 && \
        echo "The downloaded ZIP file may be corrupted or invalid." >&2 && \
        exit 1; \
    fi && \
    rm sendy.zip && \
    echo "Sendy download complete."

# Stage 2: Final image
FROM serversideup/php:8.5-fpm-apache

USER root

# Enable Apache mod_rewrite module
RUN a2enmod rewrite

# Install gettext PHP extension
RUN install-php-extensions gettext

# Copy supercronic binary from downloader stage and make it executable
COPY --from=downloader /tmp/supercronic-linux-* /usr/local/bin/supercronic
RUN chmod +x /usr/local/bin/supercronic

# Copy crontab file
COPY --chown=www-data:www-data sendy.crontab /etc/sendy.crontab

# Copy Sendy files from downloader stage
COPY --from=downloader --chown=www-data:www-data /tmp/sendy /var/www/html

# Copy our environment-aware config (overwrites vendor config.php)
COPY --chown=www-data:www-data includes/config.php /var/www/html/includes/config.php

# Copy custom entrypoint scripts
COPY --chmod=755 entrypoint.d/ /etc/entrypoint.d/

# Copy custom S6 services
COPY --chmod=755 s6-rc.d/ /etc/s6-overlay/s6-rc.d/

# Sendy environment variables
ENV APACHE_DOCUMENT_ROOT="/var/www/html"
ENV PHP_OPCACHE_ENABLE=1

# Switch to www-data user for runtime
USER www-data
VOLUME ["/var/www/html/uploads", "/var/www/html/locale"]
