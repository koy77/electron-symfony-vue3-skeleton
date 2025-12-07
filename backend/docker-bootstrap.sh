#!/bin/bash
set -e

echo "Starting Symfony bootstrap..."

# Check if Symfony is already installed
if [ ! -f "composer.json" ]; then
    echo "Creating new Symfony project..."
    composer create-project symfony/skeleton:"7.1.*" tmp_project
    mv tmp_project/* tmp_project/.* . 2>/dev/null || true
    rm -rf tmp_project
    
    echo "Installing additional packages..."
    composer require webapp
    composer require api
    composer require orm
    composer require symfony/serializer
    composer require symfony/validator
    composer require nelmio/cors-bundle
    composer require api-platform/core
    
    echo "Configuring API Platform..."
    # Enable API Platform in bundles.php
    sed -i "s/\/\/ ApiPlatform\\Bundle\\ApiPlatformBundle\\ApiPlatformBundle::class => \['all' => true\],/ApiPlatform\\Bundle\\ApiPlatformBundle\\ApiPlatformBundle::class => ['all' => true],/" config/bundles.php
    
    echo "Installing dev dependencies..."
    composer require --dev symfony/maker-bundle
    
    # Create .env.local with database configuration
    cat > .env.local <<EOF
DATABASE_URL="postgresql://app:!ChangeMe!@postgres:5432/app?serverVersion=16&charset=utf8"
CORS_ALLOW_ORIGIN='^https?://(localhost|127\.0\.0\.1)(:[0-9]+)?$'
API_PLATFORM_ENABLE_SWAGGER_UI=true
API_PLATFORM_ENABLE_REDOC=true
EOF
    
    echo "Symfony project created successfully!"
else
    echo "Symfony project already exists, installing dependencies..."
    composer install --no-interaction --optimize-autoloader
fi

# Set proper permissions
chown -R www-data:www-data /var/www/html
chmod -R 755 /var/www/html

echo "Starting services..."
exec /usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf
