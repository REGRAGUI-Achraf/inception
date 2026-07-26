#!/bin/bash

INITIALIZED_MARKER="/var/lib/mysql/.initialized"

# Use a dedicated marker instead of the packaged datadir layout.
if [ ! -f "$INITIALIZED_MARKER" ]; then

    echo "First run detected: initializing MariaDB data directory..."

    # Only bootstrap the system tables if the datadir is actually empty.
    if [ ! -d "/var/lib/mysql/mysql" ]; then
        mysql_install_db --user=mysql --datadir=/var/lib/mysql
    fi

    # Read passwords from Docker secrets only when we really need to initialize.
    DB_PASSWORD=$(cat /run/secrets/db_password)
    DB_ROOT_PASSWORD=$(cat /run/secrets/db_root_password)

    # Start mysqld temporarily in background to run setup queries.
    mysqld_safe --datadir=/var/lib/mysql &
    sleep 5

    # Create database, user, and grant permissions.
    mysql -u root <<-EOSQL
        ALTER USER 'root'@'localhost' IDENTIFIED BY '${DB_ROOT_PASSWORD}';
        CREATE DATABASE IF NOT EXISTS ${MYSQL_DATABASE};
        CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${DB_PASSWORD}';
        GRANT ALL PRIVILEGES ON ${MYSQL_DATABASE}.* TO '${MYSQL_USER}'@'%';
        FLUSH PRIVILEGES;
EOSQL

    echo "Database and user created. Shutting down temporary mysqld..."
    mysqladmin -u root -p"${DB_ROOT_PASSWORD}" shutdown

    touch "$INITIALIZED_MARKER"
fi

# Start mysqld in foreground (PID 1) so the container stays alive.
echo "Starting mysqld in foreground..."
exec mysqld_safe --datadir=/var/lib/mysql