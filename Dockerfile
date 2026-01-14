# Stage 1: Download and extract Sendy
FROM alpine:latest AS downloader
RUN apk add --no-cache curl unzip
WORKDIR /tmp

# Download and extract Sendy using build secret
RUN --mount=type=secret,id=LICENSE_KEY \
    curl -sS -o sendy.zip "https://sendy.co/download/?license=$(cat /run/secrets/LICENSE_KEY)" && \
    unzip -q sendy.zip && \
    rm sendy.zip

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
