#!/bin/bash
# --- Déclare que le script doit s'arrêter immédiatement si une commande échoue ---
set -e

# Message d'information au démarrage du script
echo "--- [Entrypoint] Démarrage du script ---"

# --- 0. Se placer dans le répertoire de l'application ---
cd /var/www/html  # On se place dans le dossier racine de Laravel

# --- 1. Gestion du fichier .env ---
if [ ! -f .env ]; then
    # Si le fichier .env n'existe pas, on copie l'exemple fourni
    echo "--- [Entrypoint] .env non trouvé, copie de .env.example... ---"
    cp .env.example .env
fi

# --- 2. Installer les dépendances PHP et Node si elles manquent ---

# Vérifie si le dossier "vendor" (dépendances PHP) existe
if [ ! -d "vendor" ]; then
  echo "--- [Entrypoint] Installation de Composer (dossier vendor manquant) ---"
  composer install --no-interaction --no-progress  # Installe les dépendances PHP sans demander d'interaction
else
  echo "--- [Entrypoint] Dossier vendor trouvé, skip composer install ---"
fi

# Vérifie si le dossier "node_modules" (dépendances JS) existe
if [ ! -d "node_modules" ]; then
  echo "--- [Entrypoint] Installation de NPM (dossier node_modules manquant) ---"
  npm install  # Installe les dépendances JS
  echo "--- [Entrypoint] Lancement de NPM run build ---"
  npm run build  # Compile les assets frontend (JS, CSS, etc.)
else
  echo "--- [Entrypoint] Dossier node_modules trouvé, skip npm install ---"
fi

# --- 3. Lancer les migrations de base de données (uniquement sur le serveur principal) ---
if [ "$RUN_MIGRATIONS" = "true" ] && [ ! -f .initialized_flag ]; then
    # Si la variable d'environnement indique qu'il faut lancer les migrations
    # et que le flag .initialized_flag n'existe pas
    echo "--- [Entrypoint - SERVEUR 1] Lancement des migrations ---"
    php artisan key:generate          # Génère la clé d'application Laravel
    php artisan migrate:fresh --seed  # Réinitialise la base et recharge les données de test
    touch .initialized_flag           # Crée un fichier flag pour ne pas relancer les migrations
elif [ "$RUN_MIGRATIONS" = "true" ]; then
    # Si les migrations sont déjà faites, on l'indique
    echo "--- [Entrypoint - SERVEUR 1] Migrations déjà effectuées (flag trouvé) ---"
elif [ ! -f "bootstrap/cache/config.php" ]; then
    # Serveur secondaire : génère au moins une clé Laravel si nécessaire
    echo "--- [Entrypoint - SERVEUR 2] Génération de la clé... ---"
    php artisan key:generate
else
    # Si tout est déjà configuré, on skip
    echo "--- [Entrypoint - SERVEUR 2] Clé déjà générée, skip. ---"
fi

# --- 4. Optimisation de Laravel pour la production ---
echo "--- [Entrypoint] Optimisation de Laravel (cache) ---"
php artisan config:cache  # Cache la configuration pour améliorer les performances
php artisan route:cache   # Cache les routes
php artisan view:cache    # Cache les vues Blade

# --- 5. Correction des permissions (très important pour Laravel) ---
echo "--- [Entrypoint] Correction des permissions pour www-data ---"
chown -R www-data:www-data /var/www/html/storage        # Donne accès en écriture au serveur web
chown -R www-data:www-data /var/www/html/bootstrap/cache

# Message final avant de lancer le serveur
echo "--- [Entrypoint] Script terminé, lancement de PHP-FPM ---"

# --- 6. Exécute la commande par défaut du container (CMD dans Dockerfile) ---
exec "$@"
