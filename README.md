# Sendy Docker

<a href="https://sendy.co/?ref=AQhuL" target="_blank"><img src="https://sendy.co/images/banners/728x90_var2.jpg" alt="Check out Sendy, a self hosted newsletter app that lets you send emails 100x cheaper via Amazon SES." width="728" height="90"/></a>



Docker image for [Sendy](https://sendy.co) - a self-hosted email newsletter application.

**Supported architectures:** `amd64`, `arm64`

## Quick Start

```bash
docker run -d \
  -e SENDY_URL=https://newsletters.example.com \
  -e MYSQL_HOST=db.example.com \
  -e MYSQL_USER=sendy \
  -e MYSQL_PASSWORD=your_password \
  -e MYSQL_DATABASE=sendy \
  -v sendy_uploads:/var/www/html/uploads \
  -p 80:8080 \
  -p 443:8443 \
  marcelorodrigo/sendy:latest
```

## Docker Compose

```yaml
services:
  sendy:
    image: marcelorodrigo/sendy:latest
    ports:
      - "80:8080"
      - "443:8443"
    environment:
      SENDY_URL: "https://newsletters.example.com"
      MYSQL_HOST: "mysql"
      MYSQL_USER: "sendy"
      MYSQL_PASSWORD: "changeme"
      MYSQL_DATABASE: "sendy"
    volumes:
      - sendy_uploads:/var/www/html/uploads
    depends_on:
      - mysql

  mysql:
    image: mysql:8.0
    environment:
      MYSQL_ROOT_PASSWORD: rootpassword
      MYSQL_DATABASE: sendy
      MYSQL_USER: sendy
      MYSQL_PASSWORD: changeme
    volumes:
      - mysql_data:/var/lib/mysql

volumes:
  sendy_uploads:
  mysql_data:
```

## Environment Variables

| Variable | Required | Default | Description |
|----------|----------|---------|-------------|
| `SENDY_URL` | Yes | - | Full URL to your Sendy installation (no trailing slash) |
| `MYSQL_HOST` | No | `mysql` | MySQL hostname |
| `MYSQL_USER` | Yes | - | MySQL username |
| `MYSQL_PASSWORD` | Yes | - | MySQL password |
| `MYSQL_DATABASE` | No | `sendy` | MySQL database name |
| `MYSQL_PORT` | No | `3306` | MySQL port |
| `MYSQL_CHARSET` | No | `utf8mb4` | Database character set |
| `SENDY_COOKIE_DOMAIN` | No | `''` | Cookie domain (rarely needs changing) |

## Custom Translations

Sendy includes English (en_US) translations by default. To provide custom translations or add additional languages, see [LOCALE.md](LOCALE.md) for detailed instructions.

## GitHub Secrets (for building)

To build this image via GitHub Actions, configure these secrets:

| Secret | Description |
|--------|-------------|
| `SENDY_LICENSE_KEY` | Your Sendy license key |
| `DOCKERHUB_USERNAME` | Docker Hub username |
| `DOCKERHUB_TOKEN` | Docker Hub access token |

## Building

Trigger the workflow manually from GitHub Actions with the desired Sendy version.
