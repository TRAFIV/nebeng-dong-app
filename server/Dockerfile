# Server Nebeng Dong: PHP 8.4 + Apache untuk Laravel.
# Dipakai sama persis di laptop (pengembangan) dan VPS.
FROM php:8.4-apache

RUN apt-get update \
    && apt-get install -y --no-install-recommends libicu-dev libzip-dev unzip git \
    && docker-php-ext-install intl zip pdo_mysql bcmath opcache \
    && a2enmod rewrite headers \
    && rm -rf /var/lib/apt/lists/*

# Apache melayani folder public/ milik Laravel.
ENV APACHE_DOCUMENT_ROOT=/var/www/html/public
RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' \
        /etc/apache2/sites-available/*.conf \
    && sed -ri -e 's!/var/www/!${APACHE_DOCUMENT_ROOT}!g' \
        /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf

COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

COPY docker/entrypoint.sh /usr/local/bin/nebeng-entrypoint
RUN sed -i 's/$//' /usr/local/bin/nebeng-entrypoint && chmod +x /usr/local/bin/nebeng-entrypoint

WORKDIR /var/www/html
ENTRYPOINT ["nebeng-entrypoint"]
CMD ["apache2-foreground"]
