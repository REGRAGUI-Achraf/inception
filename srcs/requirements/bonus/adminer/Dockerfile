FROM debian:bullseye

RUN apt-get update && \
    apt-get install -y php-fpm php-mysql curl && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN mkdir -p /var/www/html && \
    curl -L -o /var/www/html/index.php https://www.adminer.org/latest.php && \
    chown -R www-data:www-data /var/www/html

COPY conf/www.conf /etc/php/7.4/fpm/pool.d/www.conf

RUN mkdir -p /run/php

EXPOSE 9000

CMD ["php-fpm7.4", "-F"]
