# Gunakan PHP-FPM 8.1 Alpine sebagai base image
FROM php:8.1-fpm-alpine

LABEL maintainer="drg. F. Basoro <dentix.id@gmail.com>"
LABEL description="mLITE - SIM Kesehatan Aman, Ringan & Modular"
LABEL version="6.3.0"

# Update dan install paket dasar
RUN apk update && apk upgrade && \
    apk add --no-cache \
        ca-certificates \
        wget \
        libpng-dev \
        mysql-client \
        msmtp \
        perl \
        procps \
        shadow \
        libzip \
        libpng \
        libjpeg-turbo \
        libwebp \
        freetype \
        icu \
        dcmtk --repository=http://dl-cdn.alpinelinux.org/alpine/edge/testing/

# Install build dependencies dan PHP extensions
RUN apk add --no-cache --virtual build-essentials \
    icu-dev \
    icu-libs \
    zlib-dev \
    g++ \
    make \
    automake \
    autoconf \
    libzip-dev \
    libpng-dev \
    libwebp-dev \
    libjpeg-turbo-dev \
    freetype-dev \
    oniguruma-dev \
    linux-headers \
    sqlite-dev \
    && \
    docker-php-ext-configure gd --enable-gd --with-freetype --with-jpeg --with-webp && \
    docker-php-ext-install gd && \
    docker-php-ext-install mysqli && \
    docker-php-ext-install pdo_mysql && \
    docker-php-ext-install pdo_sqlite && \
    docker-php-ext-install intl && \
    docker-php-ext-install opcache && \
    docker-php-ext-install exif && \
    docker-php-ext-install zip && \
    docker-php-ext-install bcmath && \
    docker-php-ext-install mbstring && \
    docker-php-ext-install pcntl && \
    pecl install apcu && \
    docker-php-ext-enable apcu && \
    apk del build-essentials && \
    rm -rf /usr/src/php*

# Opcache configuration
RUN { \
    echo 'zend_extension=opcache'; \
    echo 'opcache.enable=1'; \
    echo 'opcache.memory_consumption=128'; \
    echo 'opcache.interned_strings_buffer=8'; \
    echo 'opcache.max_accelerated_files=10000'; \
    echo 'opcache.revalidate_freq=2'; \
    echo 'opcache.fast_shutdown=1'; \
    echo 'opcache.enable_cli=0'; \
    echo 'opcache.validate_timestamps=1'; \
} > /usr/local/etc/php/conf.d/docker-php-ext-opcache.ini

# APCu configuration
RUN { \
    echo 'extension=apcu.so'; \
    echo 'apcu.enabled=1'; \
    echo 'apcu.shm_size=64M'; \
    echo 'apcu.ttl=7200'; \
    echo 'apcu.gc_ttl=3600'; \
    echo 'apcu.enable_cli=0'; \
} > /usr/local/etc/php/conf.d/docker-php-ext-apcu.ini

# PHP-FPM tuning
RUN { \
    echo 'pm.max_children = 15'; \
    echo 'pm.start_servers = 4'; \
    echo 'pm.min_spare_servers = 2'; \
    echo 'pm.max_spare_servers = 6'; \
    echo 'pm.max_requests = 500'; \
} > /usr/local/etc/php-fpm.d/zz-tuning.conf

# Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/local/bin/composer

# Set working directory
WORKDIR /var/www/html

# Copy aplikasi
COPY . .

# Setup direktori yang memerlukan write permission
RUN mkdir -p /var/www/html/backups \
    /var/www/html/uploads \
    /var/www/html/systems/data \
    /var/www/html/tmp \
    /var/www/html/admin/tmp && \
    chmod -R 777 /var/www/html/backups \
    /var/www/html/uploads \
    /var/www/html/systems/data \
    /var/www/html/tmp \
    /var/www/html/admin/tmp

# Install composer dependencies
RUN composer install --no-dev --no-interaction --prefer-dist

# Expose port
EXPOSE 9000

# Default command
CMD ["php-fpm"]
