# Custom Translations

## Overview

Sendy includes English (en_US) translations by default in the `/locale` directory. This guide explains how to provide custom translations or add additional languages to your Sendy installation.

## Default Locale Structure

The default locale structure from Sendy looks like this:

```
/var/www/html/public/locale/
└── en_US/
    └── LC_MESSAGES/
        ├── default.po
        └── default.mo
```

- `default.po` - Portable Object file (human-readable translation source)
- `default.mo` - Machine Object file (compiled translation used by Sendy)

## Using Custom Translations

### Method 1: Mount Your Own Locale Directory

If you provide a volume mount for `/var/www/html/public/locale`, your translations will completely replace the defaults.

**docker-compose.yml:**
```yaml
services:
  sendy:
    image: marcelorodrigo/sendy:latest
    volumes:
      - sendy_uploads:/var/www/html/public/uploads
      - ./locale:/var/www/html/public/locale
```

**Docker run:**
```bash
docker run -d \
  -v ./locale:/var/www/html/public/locale \
  -e SENDY_URL=https://newsletters.example.com \
  ...
  marcelorodrigo/sendy:latest
```

### Method 2: Start with Defaults

To extract the default locale files as a starting point for customization:

```bash
# First, start your container
docker compose up -d

# Extract the default locale directory
docker cp sendy:/var/www/html/public/locale ./locale

# Now customize the files in ./locale directory
# Then mount it using Method 1 above
```

## Adding New Languages

To add a new language (e.g., Portuguese - pt_BR):

1. Create the locale structure:
```bash
mkdir -p ./locale/pt_BR/LC_MESSAGES
```

2. Add your translation files:
```bash
./locale/pt_BR/LC_MESSAGES/default.po
./locale/pt_BR/LC_MESSAGES/default.mo
```

3. Mount the locale directory as shown in Method 1

## Modifying Existing Translations

To customize the default English translations:

1. Extract defaults using Method 2 above
2. Edit `./locale/en_US/LC_MESSAGES/default.po`
3. Recompile the .mo file (if needed)
4. Mount your customized locale directory

## Example: Multiple Languages

Directory structure for supporting English and Portuguese:

```
./locale/
├── en_US/
│   └── LC_MESSAGES/
│       ├── default.po
│       └── default.mo
└── pt_BR/
    └── LC_MESSAGES/
        ├── default.po
        └── default.mo
```

Mount it with:
```yaml
volumes:
  - ./locale:/var/www/html/public/locale
```

## Verification

After mounting your custom locale:

1. Restart the container:
```bash
docker compose restart sendy
```

2. Check the logs for any locale-related errors:
```bash
docker compose logs sendy
```

3. Access your Sendy installation and verify translations are applied

## Important Notes

- **Complete replacement:** When you mount a locale directory, it completely replaces the defaults. Ensure you include all languages you need.
- **File permissions:** The container will automatically set correct permissions for locale files.
- **Empty mount:** If you mount an empty directory, Sendy may not function correctly. Always ensure your locale directory contains valid translation files.
- **.mo files required:** Sendy uses the compiled `.mo` files. Both `.po` and `.mo` files should be present.

## Troubleshooting

**Problem:** Translations not loading after mount

**Solutions:**
- Verify your locale directory structure matches the expected format
- Ensure both `.po` and `.mo` files are present
- Check file permissions (should be owned by www-data)
- Restart the container after mounting

**Problem:** Container fails to start after mounting locale

**Solutions:**
- Verify the mounted directory is not empty
- Check that the directory structure is correct
- Review container logs: `docker compose logs sendy`

## Additional Resources

- [GNU gettext Documentation](https://www.gnu.org/software/gettext/manual/gettext.html)
- [Poedit - Translation Editor](https://poedit.net/)
- [Sendy Official Documentation](https://sendy.co/api)
