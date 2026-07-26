FROM debian:bullseye

# Update package list and install MariaDB server (no interactive prompts)
RUN apt-get update && \
    apt-get install -y mariadb-server && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Copy custom MariaDB configuration (to allow connections from other containers)
COPY conf/server.cnf /etc/mysql/mariadb.conf.d/server.cnf

# Copy the initialization/startup script
COPY tools/setup.sh /usr/local/bin/setup.sh
RUN chmod +x /usr/local/bin/setup.sh

# Expose MariaDB default port
EXPOSE 3306

# Run our setup script, which will init the DB (if needed) and start mysqld
ENTRYPOINT ["/usr/local/bin/setup.sh"]