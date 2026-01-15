# Crontab Configuration for Sendy

## Overview

Sendy requires periodic background tasks to be executed to maintain proper functionality.
These tasks handle critical operations like scheduling campaigns, processing autoresponders, and importing CSV files.

To ensure these jobs run reliably in a containerized environment, our Docker image comes pre-configured with `supercronic` for task scheduling.

## Automatically Configured Cronjobs

The following background jobs are automatically configured and executed:

- **Scheduled Campaigns** - executing every `5 minutes`
- **Autoresponders** - executing every `1 minute`
- **Import Lists** - executing every `1 minute`

## ✅ Pre-configured in Our Docker Image

The Docker image already has everything set up for you. Here's what's included:

- `Supercronic` is pre-installed in the image
- The crontab file is automatically copied to `/etc/sendy.crontab`
- `Supercronic` starts automatically when the container begins, running in the background
- No additional configuration needed - it just works!

## Why Supercronic Instead of Cron?

We use [supercronic](https://github.com/aptible/supercronic) instead of traditional cron for better container compatibility:

1. **No daemon required**: Supercronic doesn't require a separate daemon service, making it perfect for containerized applications where one process is the norm.

2. **Proper error handling**: It logs both successes and failures clearly, making it easier to debug issues.

3. **Timezone support**: Built-in support for timezone configurations, important for applications serving multiple regions.

4. **Lightweight**: Minimal resource footprint - ideal for containerized environments.

5. **Multi-architecture support**: Works seamlessly on both x86_64 and ARM64 architectures (including Apple Silicon and Raspberry Pi).

For more details, visit the [supercronic GitHub repository](https://github.com/aptible/supercronic).

## Further Reading

- [Sendy Official Documentation](https://sendy.co/?r=docs)
- [Supercronic GitHub](https://github.com/aptible/supercronic)
