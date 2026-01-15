#!/bin/bash
set -e

# Validate required environment variables
missing_vars=()

[ -z "$SENDY_URL" ] && missing_vars+=("SENDY_URL")
[ -z "$MYSQL_USER" ] && missing_vars+=("MYSQL_USER")
[ -z "$MYSQL_PASSWORD" ] && missing_vars+=("MYSQL_PASSWORD")

if [ ${#missing_vars[@]} -ne 0 ]; then
    echo "ERROR: Missing required environment variables:"
    printf '  - %s\n' "${missing_vars[@]}"
    echo ""
    echo "Usage: docker run -e SENDY_URL=https://... -e MYSQL_USER=... -e MYSQL_PASSWORD=... ..."
    exit 1
fi

# Start supercronic in the background for scheduled tasks
if [ -f /etc/sendy.crontab ]; then
    echo "Starting supercronic for scheduled tasks..."
    if supercronic -test /etc/sendy.crontab; then
        supercronic /etc/sendy.crontab &
    else
        echo "ERROR: Invalid crontab syntax in /etc/sendy.crontab" >&2
        exit 1
    fi
fi

# Hand off to serversideup's S6 init system
exec /init "$@"
