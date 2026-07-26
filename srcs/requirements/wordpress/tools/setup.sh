#!/bin/bash

# Read passwords from Docker secrets
DB_PASSWORD=$(cat /run/secrets/db_password)
WP_ADMIN_PASSWORD=$(cat /run/secrets/credentials.txt)

# Wait for MariaDB to be ready (retry loop, not infinite)
COUNTER=0
MAX_TRIES=30

until mysqladmin ping -h mariadb --silent || [ $COUNTER -eq $MAX_TRIES ]; do
    echo "Waiting for MariaDB to be ready... ($COUNTER/$MAX_TRIES)"
    sleep 2
    COUNTER=$((COUNTER+1))
done

if [ $COUNTER -eq $MAX_TRIES ]; then
    echo "MariaDB did not become ready in time. Exiting."
    exit 1
fi

echo "MariaDB is ready."

# Only run the full install on first run (check if wp-config.php already exists)
if [ ! -f /var/www/html/wp-config.php ]; then

    echo "Downloading WordPress..."
    wp core download --path=/var/www/html --allow-root

    echo "Creating wp-config.php..."
    wp config create \
        --dbname=${MYSQL_DATABASE} \
        --dbuser=${MYSQL_USER} \
        --dbpass=${DB_PASSWORD} \
        --dbhost=mariadb \
        --path=/var/www/html \
        --allow-root

    echo "Installing WordPress..."
    wp core install \
        --url=${DOMAIN_NAME} \
        --title="Inception" \
        --admin_user=superviseur \
        --admin_password=${WP_ADMIN_PASSWORD} \
        --admin_email=admin@${DOMAIN_NAME} \
        --path=/var/www/html \
        --allow-root

    echo "Creating second regular user..."
    wp user create johndoe johndoe@${DOMAIN_NAME} \
        --role=author \
        --user_pass=${DB_PASSWORD} \
        --path=/var/www/html \
        --allow-root

    echo "WordPress installation complete."

fi

# Start php-fpm in foreground (PID 1) so the container stays alive
echo "Starting php-fpm in foreground..."
exec php-fpm7.4 -F