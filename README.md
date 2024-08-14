# Statamic Starter Kit
A base starter for Statamic with my preferred config and boilerplate.

## Using this starter kit
Starting a new project (with the [Statamic CLI](https://github.com/statamic/cli)):
```
statamic new my-app the-caretakers/statamic-starter
```

Or install into an existing project:
```
php please starter-kit:install the-caretakers/statamic-starter
```

## Getting started
Install frontend dependencies:
```
npm install
```

Compile assets:
```
npm run dev
```

## Exporting
To export this starter kit for use:
```
php please starter-kit:export .
```

---

# Project README

## Installation
Create an environment file:
```
cp .env.example .env
```

Set the encryption key:
```
php artisan key:generate
```

Install PHP dependencies:
```
composer install
```

Install front-end dependencies:
```
npm install
```

## Development
Start the dev server:
```
npm run dev
```

## Production
Compile the front-end assets:
```
npm run build
```

## Hosting
Laravel Forge deploy script:
```
# Pull the latest changes from git
cd $FORGE_SITE_PATH
git pull origin $FORGE_SITE_BRANCH

# Install PHP dependencies
$FORGE_COMPOSER install --no-dev --no-interaction --prefer-dist --optimize-autoloader

# Restart the PHP-FPM workers
( flock -w 10 9 || exit 1
    echo 'Restarting FPM...'; sudo -S service $FORGE_PHP_FPM reload ) 9>/tmp/fpmlock

if [ -f artisan ]; then
    # Migrate the database (if we're using one)
    # $FORGE_PHP artisan migrate --force

    # Clear and re-cache the config and caches
    $FORGE_PHP artisan config:cache
    $FORGE_PHP artisan cache:clear
    $FORGE_PHP artisan route:cache

    # Re-sync our running cron jobs
    $FORGE_PHP artisan schedule-monitor:sync

    # Kill the Horizon process (if our QUEUE_CONNECTION=redis)
    $FORGE_PHP artisan horizon:terminate

    # Pre-warm the Statamic cache
    $FORGE_PHP artisan statamic:stache:warm

    # Refresh Statamic search indexes
    $FORGE_PHP artisan statamic:search:update --all

    # Queue the generation of asset presets (warning, takes ages if queue is set to sync)
    #$FORGE_PHP artisan statamic:assets:generate-presets --queue

    # Clear and pre-warm the static cache (if STATAMIC_STATIC_CACHING_STRATEGY=full/half)
    #$FORGE_PHP artisan statamic:static:clear
    #$FORGE_PHP artisan statamic:static:warm --queue

fi


if [ -f package.json ]; then
    # Install front end dependencies
    npm ci

    # Compile the front end assets
    npm run build
fi
```

Adjustments to Nginx config. Replace the "location /" block with the below:
```
# Try Statamic's cached flat HTML files first
location / {
    try_files /static/${host}${uri}_${args}.html $uri /index.php?$args;
}

# Cache static assets
location ~* \.(gif|jpg|png|ico|otf|ttf|woff|woff2|jpeg|webp)$ {
    access_log off;
    expires max;
}
```
