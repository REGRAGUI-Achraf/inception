#!/bin/bash

FTP_PASSWORD=$(cat /run/secrets/ftp_password)

mkdir -p /var/run/vsftpd/empty
chown root:root /var/run/vsftpd /var/run/vsftpd/empty
chmod 755 /var/run/vsftpd /var/run/vsftpd/empty

if ! id "${FTP_USER}" &>/dev/null; then
    echo "Creating FTP user ${FTP_USER}..."
    useradd -d /var/www/html -s /bin/bash "${FTP_USER}"
    echo "${FTP_USER}:${FTP_PASSWORD}" | chpasswd
fi

usermod -d /var/www/html -s /bin/bash "${FTP_USER}"

chown -R "${FTP_USER}":"${FTP_USER}" /var/www/html

echo "Starting vsftpd in foreground..."
exec /usr/sbin/vsftpd /etc/vsftpd.conf
