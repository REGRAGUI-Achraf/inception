FROM debian:bullseye

RUN apt-get update && \
    apt-get install -y nginx && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

COPY html/ /var/www/html/
COPY conf/nginx.conf /etc/nginx/conf.d/default.conf

RUN rm -f /etc/nginx/sites-enabled/default

EXPOSE 8080

ENTRYPOINT ["nginx", "-g", "daemon off;"]
