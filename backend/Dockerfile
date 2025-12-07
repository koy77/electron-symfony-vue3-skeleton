FROM php:8.3-fpm

# Layer 1: Base system packages
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    ca-certificates \
    gnupg \
    && rm -rf /var/lib/apt/lists/*

# Layer 2: Development tools
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    git \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Layer 3: Archive utilities
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    zip \
    unzip \
    && rm -rf /var/lib/apt/lists/*

# Layer 4: Database libraries
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    libpq-dev \
    && rm -rf /var/lib/apt/lists/*

# Layer 5: Compression libraries
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    libzip-dev \
    && rm -rf /var/lib/apt/lists/*

# Layer 6: Internationalization libraries
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    libicu-dev \
    && rm -rf /var/lib/apt/lists/*

# Layer 7: Web server and process manager
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    nginx \
    supervisor \
    && rm -rf /var/lib/apt/lists/*

# Layer 8: PHP extensions - Database
RUN docker-php-ext-configure pdo_pgsql && \
    docker-php-ext-install pdo_pgsql

# Layer 9: PHP extensions - Basic PDO
RUN docker-php-ext-install pdo

# Layer 10: PHP extensions - Compression
RUN docker-php-ext-install zip

# Layer 11: PHP extensions - Internationalization
RUN docker-php-ext-configure intl && \
    docker-php-ext-install intl

# Layer 12: PHP extensions - Performance
RUN docker-php-ext-install opcache

# Layer 13: Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Layer 14: Set working directory
WORKDIR /var/www/html

# Layer 15: Copy bootstrap script
COPY docker-bootstrap.sh /usr/local/bin/bootstrap.sh
RUN chmod +x /usr/local/bin/bootstrap.sh

# Layer 16: Copy nginx config
COPY nginx.conf /etc/nginx/sites-available/default

# Layer 17: Copy supervisor config
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Layer 18: Create directories
RUN mkdir -p /var/www/html /run/php

# Layer 19: Set permissions
RUN chown -R www-data:www-data /var/www/html

# Layer 20: Expose port
EXPOSE 8000

# Layer 21: Run application
CMD ["/usr/local/bin/bootstrap.sh"]
