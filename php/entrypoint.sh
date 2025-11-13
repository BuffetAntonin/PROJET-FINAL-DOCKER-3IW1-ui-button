#!/bin/bash
set -e

echo "--- [Entrypoint] Démarrage du script ---"
cd /var/www/html

# 1. Création du .env
if [ ! -f .env ]; then
    cp .env.example .env
    echo "--- [Entrypoint] .env créé depuis .env.example ---"
fi

# 2. Injection des variables DB
if [ -n "$DB_HOST" ]; then
    sed -i "s|^DB_HOST=.*|DB_HOST=$DB_HOST|" .env
    sed -i "s|^DB_PORT=.*|DB_PORT=$DB_PORT|" .env
    sed -i "s|^DB_DATABASE=.*|DB_DATABASE=$DB_DATABASE|" .env
    sed -i "s|^DB_USERNAME=.*|DB_USERNAME=$DB_USERNAME|" .env
    sed -i "s|^DB_PASSWORD=.*|DB_PASSWORD=$DB_PASSWORD|" .env
    echo "--- [Entrypoint] Variables DB injectées : $DB_DATABASE @ $DB_HOST ---"
fi

# 3. Adapter le nom de l'app
if [ -n "$APP_NAME" ]; then
    sed -i "s|^APP_NAME=.*|APP_NAME=\"$APP_NAME\"|" .env
    echo "--- [Entrypoint] APP_NAME défini sur $APP_NAME ---"
fi

# 4.  Installation des dépendances
if [ ! -d "vendor" ]; then
    echo "--- [Entrypoint] Installation des dépendances PHP ---"
    COMPOSER_PROCESS_TIMEOUT=0 composer install --no-interaction --no-progress --prefer-dist --no-dev
fi


if [ ! -d "node_modules" ]; then
    echo "--- [Entrypoint] Installation des dépendances Node.js ---"
    npm install
    npm run build
fi

# 6. Génération de la clé Laravel
if ! grep -q "APP_KEY=base64:" .env; then
    echo "--- [Entrypoint] Génération de la clé Laravel ---"
    php artisan key:generate --force
else
    echo "--- [Entrypoint] APP_KEY déjà présente ---"
fi

# 7. Migrations
if [ "$RUN_MIGRATIONS" = "true" ]; then
    echo "--- [Entrypoint] Lancement des migrations et seed ---"
    php artisan migrate:fresh --seed --force
fi

# 8. Permissions
echo "--- [Entrypoint] Correction des permissions ---"
chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache
chmod -R 775 /var/www/html/storage /var/www/html/bootstrap/cache

echo "--- [Entrypoint] ✅ Script terminé, lancement de PHP-FPM ---"
exec "$@"