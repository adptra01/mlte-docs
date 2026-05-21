# Containerfile — Podman build untuk mLITE
# Identik dengan Dockerfile. Podman 100% kompatibel dengan Dockerfile format.
# File ini disediakan untuk eksplisit mendukung Podman-native build.
# Untuk build: podman build -t mlite-php -f Containerfile .

FROM php:8.1-fpm-alpine

LABEL maintainer="drg. F. Basoro <dentix.id@gmail.com>"
LABEL description="mLITE - SIM Kesehatan Aman, Ringan & Modular"
LABEL version="6.3.0"

RUN apk update && apk upgrade && \
    apk add --no-cache \
        ca-certificates wget libpng-dev mysql-client msmtp perl \
        procps shadow libzip libpng libjpeg-turbo libwebp freetype icu \
        dcmtk --repository=http://dl-cdn.alpinelinux.org/alpine/edge/testing/

RUN apk add --no-cache --virtual build-essentials \
    icu-dev icu-libs zlib-dev g++ make automake autoconf libzip-dev \
    libpng-dev libwebp-dev libjpeg-turbo-dev freetype-dev oniguruma-dev \
    linux-headers sqlite-dev && \
    docker-php-ext-configure gd --enable-gd --with-freetype --with-jpeg --with-webp && \
    docker-php-ext-install gd mysqli pdo_mysql pdo_sqlite intl opcache exif zip bcmath mbstring pcntl && \
    apk del build-essentials && rm -rf /usr/src/php*

COPY --from=composer:latest /usr/bin/composer /usr/local/bin/composer
WORKDIR /var/www/html
COPY . .

RUN mkdir -p /var/www/html/backups /var/www/html/uploads /var/www/html/systems/data /var/www/html/tmp /var/www/html/admin/tmp && \
    chmod -R 777 /var/www/html/backups /var/www/html/uploads /var/www/html/systems/data /var/www/html/tmp /var/www/html/admin/tmp

RUN composer install --no-dev --no-interaction --prefer-dist

EXPOSE 9000
CMD ["php-fpm"]
