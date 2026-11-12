#!/bin/sh
# Folder yang ditulis Laravel (log, cache, sesi) harus bisa ditulis Apache
# (user www-data), walaupun kode dipasang dari folder milik user lain.
set -e
cd /var/www/html

# Paket PHP belum terpasang (container baru/volume vendor kosong): pasang dulu.
# Di production tanpa paket pengembangan.
if [ ! -f vendor/autoload.php ]; then
    APP_ENV_VALUE=$(grep -E '^APP_ENV=' .env 2>/dev/null | cut -d= -f2)
    if [ "$APP_ENV_VALUE" = "production" ]; then
        composer install --no-interaction --prefer-dist --no-dev --optimize-autoloader
    else
        composer install --no-interaction --prefer-dist
    fi
fi
mkdir -p storage/logs storage/framework/cache storage/framework/sessions \
    storage/framework/views bootstrap/cache
chown -R www-data:www-data storage bootstrap/cache 2>/dev/null || true
chmod -R ug+rwX storage bootstrap/cache 2>/dev/null || true
exec "$@"
