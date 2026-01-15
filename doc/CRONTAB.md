# Crontab Configuration for Sendy

## Overview

Sendy requires periodic background tasks to be executed to maintain proper functionality. These tasks handle critical operations like scheduling campaigns, processing autoresponders, and importing CSV files. To ensure these jobs run reliably in a containerized environment, our Docker image comes pre-configured with **supercronic** for task scheduling.

## ✅ Pre-configured in Our Docker Image

Great news! The Docker image already has everything set up for you. Here's what's included:

- **Supercronic** is pre-installed in the image (v0.2.41)
- The crontab file is automatically copied to `/etc/sendy.crontab`
- Supercronic starts automatically when the container begins, running in the background
- No additional configuration needed - it just works!

## Why Supercronic Instead of Cron?

We use [supercronic](https://github.com/aptible/supercronic) instead of traditional cron for better container compatibility:

1. **No daemon required**: Supercronic doesn't require a separate daemon service, making it perfect for containerized applications where one process is the norm.

2. **Proper error handling**: It logs both successes and failures clearly, making it easier to debug issues.

3. **Timezone support**: Built-in support for timezone configurations, important for applications serving multiple regions.

4. **Lightweight**: Minimal resource footprint - ideal for containerized environments.

5. **Multi-architecture support**: Works seamlessly on both x86_64 and ARM64 architectures (including Apple Silicon and Raspberry Pi).

For more details, visit the [supercronic GitHub repository](https://github.com/aptible/supercronic).

## Configured Jobs in sendy.crontab

### 1. 📨 Scheduling Campaigns
**Schedule**: Every 5 minutes (`*/5 * * * *`)

```
*/5 * * * * curl -i http://localhost/scheduled.php
```

This job checks for campaigns scheduled to be sent and processes them. If you have campaigns set to send at specific times, this task ensures they're sent on schedule.

**Why every 5 minutes?** Provides a reasonable balance between real-time delivery and server load. Campaigns are typically scheduled with some buffer time, so 5-minute intervals are sufficient for most use cases.

---

### 2. 🤖 Autoresponders
**Schedule**: Every 1 minute (`*/1 * * * *`)

```
*/1 * * * * curl -i http://localhost/autoresponders.php
```

This job processes automated responses that are triggered based on subscriber actions or time-based rules. It's one of Sendy's core features for creating engagement workflows.

**Why every minute?** Autoresponders need to be responsive to subscriber actions, so more frequent execution ensures timely delivery of automated messages.

---

### 3. 📥 CSV Importer
**Schedule**: Every 1 minute (`*/1 * * * *`)

```
*/1 * * * * curl -i http://localhost/import-csv.php
```

This job processes CSV file uploads for batch importing subscribers into your lists. It works through files queued by the Sendy interface.

**Why every minute?** Users uploading CSV files expect relatively quick processing. Frequent execution ensures imports are handled promptly without overwhelming the server.

---

## How It Works

When your Docker container starts:

1. The entrypoint script checks for the existence of `/etc/sendy.crontab`
2. Supercronic is launched in the background with this crontab file
3. At the specified intervals, supercronic executes the corresponding curl commands
4. Each job calls the respective PHP script via HTTP, just as if run from a cron job on a traditional server
5. The container's main process (Apache/PHP-FPM) continues running normally

## Customizing the Schedule

If you need to adjust the scheduling intervals, you have two options:

### Option 1: Mount a Custom Crontab (Recommended)
Mount your own crontab file when running the container:

```bash
docker run -v ./my-crontab:/etc/sendy.crontab ...
```

### Option 2: Modify the Source
Edit the `sendy.crontab` file in the repository, rebuild the image, and deploy.

## Crontab Syntax Reference

If you need to customize the schedule, here's a quick reference for crontab syntax:

```
┌───────────── minute (0 - 59)
│ ┌───────────── hour (0 - 23)
│ │ ┌───────────── day of month (1 - 31)
│ │ │ ┌───────────── month (1 - 12)
│ │ │ │ ┌───────────── day of week (0 - 6) (Sunday to Saturday)
│ │ │ │ │
│ │ │ │ │
* * * * * command to execute
```

Common expressions:
- `*/5 * * * *` = Every 5 minutes
- `*/1 * * * *` = Every minute
- `0 * * * *` = Every hour at minute 0
- `0 0 * * *` = Every day at midnight

## Monitoring and Debugging

Supercronic logs to the container's stdout/stderr. You can view logs with:

```bash
docker logs <container-name>
```

Look for entries like:
```
Starting supercronic for scheduled tasks...
supercronic: scheduled the following jobs:
supercronic: job 1: "*/5 * * * * curl -i http://localhost/scheduled.php"
```

## Troubleshooting

**Q: Why aren't my scheduled campaigns being sent?**
- Check that the crontab file exists at `/etc/sendy.crontab`
- Verify container logs: `docker logs <container-name>`
- Ensure the container's internal HTTP routing is working correctly

**Q: Can I disable a job temporarily?**
- Yes! Comment out the line in the crontab file with a `#` at the beginning
- Example: `# */5 * * * * curl -i http://localhost/scheduled.php`

**Q: How do I increase or decrease job frequency?**
- Modify the crontab expression in the `sendy.crontab` file
- Rebuild and redeploy, or mount a custom crontab file as described above

## Further Reading

- [Sendy Official Documentation](https://sendy.co/?r=docs)
- [Supercronic GitHub](https://github.com/aptible/supercronic)
- [Cron Expression Syntax](https://crontab.guru/) - Interactive cron expression builder

