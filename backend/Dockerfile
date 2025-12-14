FROM php:8.3-fpm

# Install all system packages in a single layer
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    ca-certificates \
    gnupg \
    git \
    curl \
    zip \
    unzip \
    libpq-dev \
    libzip-dev \
    libicu-dev \
    nginx \
    supervisor \
    && rm -rf /var/lib/apt/lists/*

# Layer 2: PHP extensions - Database
RUN docker-php-ext-configure pdo_pgsql && \
    docker-php-ext-install pdo_pgsql

# Layer 3: PHP extensions - Basic PDO
RUN docker-php-ext-install pdo

# Layer 4: PHP extensions - Compression
RUN docker-php-ext-install zip

# Layer 5: PHP extensions - Internationalization
RUN docker-php-ext-configure intl && \
    docker-php-ext-install intl

# Layer 6: PHP extensions - Performance
RUN docker-php-ext-install opcache

# Layer 7: Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Layer 8: Set working directory
WORKDIR /var/www/html

# Layer 9: Copy nginx config
COPY nginx.conf /etc/nginx/sites-available/default

# Layer 10: Copy supervisor config
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Layer 11: Create directories
RUN mkdir -p /var/www/html /run/php

# Layer 12: Set permissions
RUN chown -R www-data:www-data /var/www/html

# Layer 13: Expose port
EXPOSE 8000

# Layer 14: Run supervisord to start php-fpm and nginx
CMD ["/usr/bin/supervisord","-c","/etc/supervisor/conf.d/supervisord.conf"]
