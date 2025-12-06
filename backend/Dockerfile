FROM php:8.3-fpm

# Install system dependencies
RUN apt-get update
RUN apt-get install -y git
RUN apt-get install -y curl
RUN apt-get install -y libpq-dev
RUN apt-get install -y libzip-dev
RUN apt-get install -y libicu-dev
RUN apt-get install -y zip
RUN apt-get install -y unzip
RUN apt-get install -y nginx
RUN apt-get install -y supervisor
RUN docker-php-ext-configure intl
RUN docker-php-ext-install pdo
RUN docker-php-ext-install pdo_pgsql
RUN docker-php-ext-install zip
RUN docker-php-ext-install intl
RUN docker-php-ext-install opcache
RUN rm -rf /var/lib/apt/lists/*

# Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Set working directory
WORKDIR /var/www/html

# Copy bootstrap script
COPY docker-bootstrap.sh /usr/local/bin/bootstrap.sh
RUN chmod +x /usr/local/bin/bootstrap.sh

# Copy nginx config
COPY nginx.conf /etc/nginx/sites-available/default

# Copy supervisor config
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Create necessary directories
RUN mkdir -p /var/www/html
RUN mkdir -p /run/php

# Set permissions
RUN chown -R www-data:www-data /var/www/html

# Expose port 8000
EXPOSE 8000

# Run bootstrap script and start services
CMD ["/usr/local/bin/bootstrap.sh"]
