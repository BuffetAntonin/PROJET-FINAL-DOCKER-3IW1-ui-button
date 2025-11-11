# --- 1. Image de base ---
FROM php:8.2-fpm

# --- 2. Installer les dépendances système et extensions Laravel ---
RUN apt-get update && apt-get install -y \
    git \
    unzip \
    curl \
    libzip-dev \
    zip \
    nodejs \
    npm \
    && docker-php-ext-install pdo pdo_mysql zip

# --- 3. Installer Composer ---
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# --- 4. Créer le répertoire de travail ---
WORKDIR /var/www/html

# --- 5. Copier l'entrypoint ---
COPY entrypoint.sh /var/www/html/entrypoint.sh
RUN chmod +x /var/www/html/entrypoint.sh

# --- 6. Définir l'entrypoint ---
ENTRYPOINT ["/var/www/html/entrypoint.sh"]

# --- 7. Commande par défaut (php-fpm) ---
CMD ["php-fpm"]
