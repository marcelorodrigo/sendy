# Sendy Docker

<a href="https://sendy.co/?ref=AQhuL" target="_blank"><img src="https://sendy.co/images/banners/728x90_var2.jpg" alt="Check out Sendy, a self hosted newsletter app that lets you send emails 100x cheaper via Amazon SES." width="728" height="90"/></a>

## What is Sendy?

[Sendy](https://sendy.co) is a self-hosted email newsletter application that lets you send trackable emails via Amazon
Simple Email Service (SES). This makes it possible for you to send authenticated bulk emails at an insanely low price
without sacrificing deliverability.

## Community Contribution

This is a **community maintained Docker image** and is **not an official Sendy product** or endorsed by Sendy.
It is provided _as-is_ for community use.

For official Sendy licensing, support and documentation: please visit [Sendy.co](https://sendy.co).

## Features

- 🏭 **Production Ready**: Apache/PHP image based on ServerSideUp/PHP images
- ⚡ **High Performance**: Fine-tuned for optimal performance with `opcache` optimized for production
- 🔒 **Security**: Runs as non-root user
- 💚 **Health Checks**: Native health check support
- ⚙️ **Easy Configuration**: Simple and intuitive setup
- ☁️ **CloudFlare Support**: Native CloudFlare support with real IP addresses from trusted proxies
- 📊 **Unified Logging**: All logs directed to STDOUT & STDERR for centralized output
- 🔧 **Intelligent Init System**: Apache + FPM + s6 overlay
- ✅ **Validation**: Required configuration validation on start-up to prevent mistakes
- 🌐 **Web Server Features**: `.htaccess` support with `mod_rewrite` enabled
- 📦 **PHP Extensions**: All PHP extensions required by Sendy installed and enabled
- 🚀 **Latest PHP**: PHP 8.5 with opcache enabled
- 💾 **Volume Support**: Support for `/upload` volume
- 🌍 **Translations**: Support for custom Sendy translations
- 🏗️ **Multi-Architecture**: `amd64` and `arm64` native support

## Quick Start
If you already have a `MySQL` database for `Sendy`, you can run the container with the following command.
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
A full example with `MySQL` using `docker-compose` is provided below.

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
      # - ./locale:/var/www/html/locale  # Optional: provide custom translations (see LOCALE.md)
    depends_on:
      - mysql

  mysql:
    image: mysql:8.4
    environment:
      MYSQL_ROOT_PASSWORD: toor
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
| `SENDY_URL` | Yes | - | URL to your Sendy installation (without the trailing slash) |
| `MYSQL_HOST` | No | `mysql` | MySQL hostname |
| `MYSQL_USER` | Yes | - | MySQL username |
| `MYSQL_PASSWORD` | Yes | - | MySQL password |
| `MYSQL_DATABASE` | No | `sendy` | MySQL database name |
| `MYSQL_PORT` | No | `3306` | MySQL port |
| `MYSQL_CHARSET` | No | `utf8mb4` | Database character set |
| `SENDY_COOKIE_DOMAIN` | No | `''` | Cookie domain (rarely needs changing) |

## Custom Translations

Sendy includes English (en_US) translations by default.
To provide custom translations or add additional languages, see [LOCALE.md](LOCALE.md) for detailed instructions.

## Building your own image

You can build your own image by cloning this repository. A Sendy license is required to use the application.

```bash
git clone git@github.com:marcelorodrigo/sendy.git
export SENDY_LICENSE_KEY=your_license_key_here
docker build -t my-sendy-docker --build-arg .
```
Make sure to keep your license key safe and never commit it to version control or share it publicly.