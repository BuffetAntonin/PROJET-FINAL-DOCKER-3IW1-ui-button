FROM bitnami/php-fpm:8.2

LABEL maintainer="BUFFET Antonin et AKPOVI Amen Manassé"

# --- 1. Installer Node et npm ---
USER root
RUN apt-get update && apt-get install -y curl npm && \
    curl -fsSL https://deb.nodesource.com/setup_18.x | bash - && \
    apt-get install -y nodejs && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# --- 2. Installer Composer ---
RUN curl -sS https://getcomposer.org/installer | php && \
    mv composer.phar /usr/local/bin/composer

# --- 3. Nettoyage complet avant installation ---
RUN rm -rf ./vendor ./node_modules || true

# --- 4. Installation Laravel et build frontend ---
RUN composer install --no-interaction --prefer-dist && \
    npm install && \
    npm run build

# --- 5. Initialisation Laravel (premier démarrage uniquement) ---
RUN cp .env.example .env && \
    php artisan key:generate && \
    php artisan migrate:fresh --seed || true

# --- 8. Droits sur les fichiers ---
RUN chown -R 1001:1001 /app

EXPOSE 9000
CMD ["php-fpm"]
