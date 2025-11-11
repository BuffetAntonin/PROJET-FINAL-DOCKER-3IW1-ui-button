# --- 1. Image de base ---
FROM php:8.1-fpm
# On utilise l'image officielle PHP 8.1 avec FPM (FastCGI Process Manager) pour servir Laravel

# --- 2. Installer les dépendances système et extensions Laravel ---
RUN apt-get update && apt-get install -y \
    git \
    unzip \
    curl \
    libzip-dev \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    nodejs \
    npm \
    dos2unix && \
    docker-php-ext-install pdo pdo_mysql zip gd
    # Installe les extensions PHP nécessaires :
    # pdo et pdo_mysql → connexion à la base MySQL
    # zip → manipulation des fichiers zip
    # gd → manipulation d’images

# --- 3. Installer Composer ---
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer
# On copie Composer depuis l'image officielle Composer pour gérer les dépendances PHP

# --- 4. Créer le répertoire de travail ---
WORKDIR /var/www/html
# Définit le répertoire de travail à l’intérieur du container (où sera placé Laravel)

# --- 5. Copier l'entrypoint et le rendre exécutable ---
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN dos2unix /usr/local/bin/entrypoint.sh   # Convertit le script pour éviter les erreurs de fin de ligne
RUN chmod +x /usr/local/bin/entrypoint.sh   # Rend le script exécutable

# --- 6. Définir l'entrypoint ---
ENTRYPOINT ["entrypoint.sh"]
# L’entrypoint sera exécuté à chaque démarrage du container.
# Permet de gérer l’installation des dépendances, migrations, permissions, etc.

# --- 7. Commande par défaut (lancée par l'entrypoint) ---
CMD ["php-fpm"]
# Lance PHP-FPM pour servir l’application Laravel
# CMD peut être remplacée si on lance le container avec une autre commande
