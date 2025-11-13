FROM php:8.1-fpm

RUN apt-get update && apt-get install -y \
    git \
    unzip \
    curl \
    libzip-dev \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    dos2unix && \
    docker-php-ext-install pdo pdo_mysql zip gd && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Installe les extensions PHP nécessaires et Nodejs :
# pdo et pdo_mysql → connexion à la base MySQL
# zip → manipulation des fichiers zip
# gd → manipulation d’images


RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - && \
    apt-get install -y nodejs && \
    apt-get clean && rm -rf /var/lib/apt/lists/*


COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

WORKDIR /var/www/html


# Copier l'entrypoint 
# Convertir le script pour éviter les erreurs de fin de ligne
# Rendre le script exécutable

COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN dos2unix /usr/local/bin/entrypoint.sh   
RUN chmod +x /usr/local/bin/entrypoint.sh   


ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["php-fpm"]
