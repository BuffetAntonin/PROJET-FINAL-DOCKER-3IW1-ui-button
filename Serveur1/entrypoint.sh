#!/bin/bash
set -e

APP_DIR=/var/www/html

# --- 1. Nettoyage total du dossier ---
rm -rf $APP_DIR/*

# --- 2. Installer les dépendances Laravel & Node ---
composer install
npm install
npm run build

# --- 3. Laravel setup (premier démarrage uniquement) ---
if [ ! -f $APP_DIR/.initialized ]; then
    php artisan key:generate
    php artisan migrate:fresh --seed
    touch $APP_DIR/.initialized
fi

# --- 4. Lancer PHP-FPM ---
php-fpm
