#!/bin/bash
set -e

# =============================================================================
# COMMAND LINE PARSING
# =============================================================================
# Parse command line arguments
BUILD_ON_SERVER=false
while [[ $# -gt 0 ]]; do
    case $1 in
        --server-build)
            BUILD_ON_SERVER=true
            shift
            ;;
        *)
            echo "Unknown option: $1"
            echo "Usage: $0 [--server-build]"
            exit 1
            ;;
    esac
done

# =============================================================================
# CONFIGURATION
# =============================================================================
# Configuration (defaults but can be set via environment)
SSH_USER="${DEPLOY_SSH_USER:-defaultuser}"
SERVER_IP="${DEPLOY_SERVER_IP:-223.165.64.179}"
SERVER_APP_PATH="${DEPLOY_SERVER_PATH:-/container/application}"

# Derived variables
SSH_HOST="${SSH_USER}@${SERVER_IP}"

# =============================================================================
# STEP 1: BUILD ASSETS LOCALLY (DEFAULT) OR PREPARE FOR SERVER BUILD
# =============================================================================
if [ -f package.json ]; then
    if [ "$BUILD_ON_SERVER" = true ]; then
        echo "Assets will be built on server..."
    else
        echo "Building assets locally..."
        npm run build
    fi
fi

# =============================================================================
# STEP 2: PULL LATEST CODE ON SERVER
# =============================================================================
echo "Pulling latest code on server..."
ssh "$SSH_HOST" "cd $SERVER_APP_PATH && git pull"

# =============================================================================
# STEP 3: DEPLOY ASSETS (LOCAL BUILD) OR BUILD ON SERVER
# =============================================================================
# Deploy assets if built locally
if [ -f package.json ] && [ "$BUILD_ON_SERVER" = false ]; then
    echo "Deploying assets to server..."
    rsync -avz --delete "./public/build/" "$SSH_HOST:$SERVER_APP_PATH/public/build/"
fi

# Build assets on server if flag is set
if [ -f package.json ] && [ "$BUILD_ON_SERVER" = true ]; then
    echo "Compiling assets on server..."
    ssh "$SSH_HOST" "cd $SERVER_APP_PATH && npm i && npm run build"
fi

# =============================================================================
# STEP 4: INSTALL PHP DEPENDENCIES
# =============================================================================
echo "Installing PHP dependencies..."
ssh "$SSH_HOST" "cd $SERVER_APP_PATH && composer install --no-dev --no-interaction --prefer-dist --optimize-autoloader"

# =============================================================================
# STEP 5: RUN LARAVEL-SPECIFIC COMMANDS
# =============================================================================
if [ -f artisan ]; then
    # Run database migrations
    echo "Running migrations..."
    ssh "$SSH_HOST" "cd $SERVER_APP_PATH && php artisan migrate --force"

    # Clear and rebuild caches, restart queues, sync schedule monitor
    echo "Running Laravel commands..."
    ssh "$SSH_HOST" "cd $SERVER_APP_PATH && php artisan config:cache"
    ssh "$SSH_HOST" "cd $SERVER_APP_PATH && php artisan cache:clear"
    ssh "$SSH_HOST" "cd $SERVER_APP_PATH && php artisan queue:restart"
    ssh "$SSH_HOST" "cd $SERVER_APP_PATH && php artisan schedule-monitor:sync"
fi

# =============================================================================
# STEP 6: RUN STATAMIC-SPECIFIC COMMANDS
# =============================================================================
if [ -f please ]; then
    echo "Running Statamic commands..."
    # Clear Statamic caches
    ssh "$SSH_HOST" "cd $SERVER_APP_PATH && php artisan statamic:static:clear"
    ssh "$SSH_HOST" "cd $SERVER_APP_PATH && php artisan statamic:stache:clear"
    # Rebuild search index
    ssh "$SSH_HOST" "cd $SERVER_APP_PATH && php artisan statamic:search:update --all"
fi

# =============================================================================
# STEP 7: CLEAR PHP OPCACHE
# =============================================================================
echo "Clearing OPcache..."
ssh "$SSH_HOST" "php -r \"if (function_exists('opcache_reset')) { opcache_reset(); }\""

echo "Deployment complete 🚀"
