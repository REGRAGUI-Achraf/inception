#!/bin/bash
# Read passwords from Docker secrets
DB_PASSWORD=$(cat /run/secrets/db_password)
DB_ROOT_PASSWORD=$(cat /run/secrets/db_root_password)
WP_ADMIN_PASSWORD=$(cat /run/secrets/credentials)
# Wait for MariaDB to be ready (retry loop, not infinite)
COUNTER=0
MAX_TRIES=30
until mysql --protocol=TCP \
    -h mariadb \
    -u "${MYSQL_USER}" \
    -p"${DB_PASSWORD}" \
    -e "SELECT 1;" >/dev/null 2>&1 || [ $COUNTER -eq $MAX_TRIES ]; do
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
        --admin_user=superachraf \
        --admin_password=${DB_ROOT_PASSWORD} \
        --admin_email=superachraf@${DOMAIN_NAME} \
        --path=/var/www/html \
        --allow-root
    echo "Creating regular author user..."
    wp user create achraf achraf@${DOMAIN_NAME} \
        --role=author \
        --user_pass=${WP_ADMIN_PASSWORD} \
        --path=/var/www/html \
        --allow-root

    echo "Configuring Redis cache..."
    wp config set WP_REDIS_HOST redis --path=/var/www/html --allow-root
    wp config set WP_REDIS_PORT 6379 --path=/var/www/html --allow-root --raw

    echo "Installing and activating Redis Object Cache plugin..."
    wp plugin install redis-cache --activate --path=/var/www/html --allow-root
    wp redis enable --path=/var/www/html --allow-root

    echo "WordPress installation complete."
fi
# Start php-fpm in foreground (PID 1) so the container stays alive
echo "Starting php-fpm in foreground..."
exec php-fpm7.4 -F
