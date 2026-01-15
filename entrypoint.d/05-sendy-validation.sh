#!/bin/sh
###################################################
# Usage: 05-sendy-validation.sh
###################################################
# This script validates required environment variables for Sendy.
# It runs during container initialization before the webserver config.
script_name="sendy-validation"

# Validate required environment variables
missing_vars=""
[ -z "$SENDY_URL" ] && missing_vars="$missing_vars SENDY_URL"
[ -z "$MYSQL_USER" ] && missing_vars="$missing_vars MYSQL_USER"
[ -z "$MYSQL_PASSWORD" ] && missing_vars="$missing_vars MYSQL_PASSWORD"

if [ -n "$missing_vars" ]; then
    echo "🛑 ERROR ($script_name): Missing required environment variables:$missing_vars" >&2
    echo "" >&2
    echo "Usage: docker run -e SENDY_URL=https://... -e MYSQL_USER=... -e MYSQL_PASSWORD=... ..." >&2
    exit 1
fi

if [ "$LOG_OUTPUT_LEVEL" = "debug" ]; then
    echo "✅ ($script_name): All required environment variables are set."
fi
