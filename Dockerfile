# Stage 1: Download and extract Sendy
FROM alpine:latest AS downloader
RUN apk add --no-cache curl unzip
WORKDIR /tmp

# Download and extract Sendy using build secret
RUN --mount=type=secret,id=LICENSE_KEY \
    set -e && \
    echo "Downloading Sendy..." && \
    if ! curl -fsSL -o sendy.zip "https://sendy.co/download/?license=$(cat /run/secrets/LICENSE_KEY)"; then \
        echo "ERROR: Failed to download Sendy. Please verify:" >&2 && \
        echo "  - Your LICENSE_KEY secret is correct" >&2 && \
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

# Sendy doesn't use a /public subdirectory
ENV APACHE_DOCUMENT_ROOT=/var/www/html

# Enable OPcache for production performance
ENV PHP_OPCACHE_ENABLE=1

# Copy Sendy files from downloader stage
COPY --from=downloader --chown=www-data:www-data /tmp/sendy /var/www/html

# Copy our environment-aware config (overwrites vendor config.php)
COPY --chown=www-data:www-data includes/config.php /var/www/html/includes/config.php

# Copy and set up entrypoint
USER root
COPY docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

USER www-data

VOLUME ["/var/www/html/uploads", "/var/www/html/locale"]

ENTRYPOINT ["docker-entrypoint.sh"]
