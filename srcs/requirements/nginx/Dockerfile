FROM debian:bullseye

RUN apt-get update && apt-get install -y nginx openssl

RUN openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout /etc/nginx/inception.key \
    -out /etc/nginx/inception.crt \
    -subj "/CN=aregragu.42.fr"

COPY tools/nginx.conf /etc/nginx/conf.d/

EXPOSE 443

CMD ["nginx", "-g", "daemon off;"]