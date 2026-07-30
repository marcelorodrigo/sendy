# Stage 1: Download and extract Sendy, install supercronic
FROM alpine:3.24.1 AS downloader
RUN apk add --no-cache curl unzip
WORKDIR /tmp

# Install supercronic for cron jobs (multi-architecture support)
ARG TARGETARCH
ENV SUPERCRONIC_VERSION=v0.2.48
RUN set -e && \
    if [ "$TARGETARCH" = "arm64" ]; then \
        SUPERCRONIC_URL="https://github.com/aptible/supercronic/releases/download/${SUPERCRONIC_VERSION}/supercronic-linux-arm64" && \
        SUPERCRONIC_SHA256SUM="50ae8755e04fa72812d0a1bc47a112a856811cc91cce7b6c875c378a850788bc"; \
    else \
        SUPERCRONIC_URL="https://github.com/aptible/supercronic/releases/download/${SUPERCRONIC_VERSION}/supercronic-linux-amd64" && \
        SUPERCRONIC_SHA256SUM="88c1b66b94c486f972fdd1a4d1f901e3e75ff04f749cddd60c5db573e3a33c6c"; \
    fi && \
    curl -fsSLO "$SUPERCRONIC_URL" && \
    echo "${SUPERCRONIC_SHA256SUM}  $(basename "$SUPERCRONIC_URL")" | sha256sum -c - && \
    echo "Supercronic download verified."

# Expected Sendy version, asserted against the actual download below
ARG SENDY_VERSION

# Download and extract Sendy using build secret
RUN --mount=type=secret,id=SENDY_LICENSE_KEY \
    set -e && \
    if [ -z "$SENDY_VERSION" ]; then \
        echo "ERROR: SENDY_VERSION build argument is required but was not provided." >&2 && \
        echo "Pass it with: docker build --build-arg SENDY_VERSION=<X.Y.Z>" >&2 && \
        exit 1; \
    fi && \
    echo "Downloading Sendy (expecting version ${SENDY_VERSION})..." && \
    if ! curl -fsSL -D headers.txt -o sendy.zip "https://sendy.co/download/?license=$(cat /run/secrets/SENDY_LICENSE_KEY)"; then \
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
    echo "Verifying downloaded version..." && \
    ACTUAL_VERSION=$(grep -i 'content-disposition' headers.txt | grep -oiE 'sendy-[0-9]+(\.[0-9]+)+' | grep -oE '[0-9]+(\.[0-9]+)+' | head -n1) && \
    if [ -z "$ACTUAL_VERSION" ]; then \
        echo "ERROR: Could not determine the downloaded Sendy version from the response headers." >&2 && \
        echo "Expected a 'Content-Disposition' header with a filename like 'sendy-X.Y.Z.zip'." >&2 && \
        exit 1; \
    fi && \
    if [ "$ACTUAL_VERSION" != "$SENDY_VERSION" ]; then \
        echo "ERROR: Version mismatch. Requested '${SENDY_VERSION}' but sendy.co served '${ACTUAL_VERSION}'." >&2 && \
        echo "The download endpoint only serves the latest version your license is entitled to." >&2 && \
        echo "Either build version '${ACTUAL_VERSION}', or upgrade the license to reach '${SENDY_VERSION}'." >&2 && \
        exit 1; \
    fi && \
    echo "Verified: downloaded version ${ACTUAL_VERSION} matches requested version." && \
    echo "Extracting Sendy..." && \
    unzip -q sendy.zip && \
    if [ ! -d "sendy" ]; then \
        echo "ERROR: Sendy directory not found after extraction." >&2 && \
        echo "The downloaded ZIP file may be corrupted or invalid." >&2 && \
        exit 1; \
    fi && \
    rm sendy.zip headers.txt && \
    echo "Sendy download complete (version ${ACTUAL_VERSION})."

# Stage 2: Final image
FROM serversideup/php:8.5-fpm-apache

USER root

# Enable Apache mod_rewrite module
RUN a2enmod rewrite

# Install gettext/calendar PHP extensions
RUN install-php-extensions gettext calendar

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
