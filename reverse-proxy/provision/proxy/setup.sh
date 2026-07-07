#!/bin/bash

# evita interazioni durante l'installazione di pacchetti
export DEBIAN_FRONTEND=noninteractive

# aggiornamento dei pacchetti e installazione di apache e openssl
apt-get update -y
apt-get install -y apache2 openssl

# abilitazione dei moduli di Apache 
a2enmod proxy
a2enmod proxy_http
a2enmod ssl
a2enmod headers

# creazione del certificato
mkdir -p /etc/apache2/ssl
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout /etc/apache2/ssl/apache-selfsigned.key \
  -out /etc/apache2/ssl/apache-selfsigned.crt \
  -subj "/C=IT/ST=Stato/L=Citta/O=Sviluppo/OU=IT/CN=192.168.56.10"

# configurazione dei virtualhost per il reverse proxy
cat << 'EOF' > /etc/apache2/sites-available/reverse-proxy.conf

<VirtualHost *:443>
    ServerName serverUbuntuServer
    
    SSLEngine on
    SSLCertificateFile /etc/apache2/ssl/apache-selfsigned.crt
    SSLCertificateKeyFile /etc/apache2/ssl/apache-selfsigned.key

    ProxyRequests Off
    ProxyPreserveHost On

    # Path Routing verso i Backend
    ProxyPass /blue http://192.168.56.20/blue
    ProxyPassReverse /blue http://192.168.56.20/blue

    ProxyPass /red http://192.168.56.30/red
    ProxyPassReverse /red http://192.168.56.30/red

    ErrorLog ${APACHE_LOG_DIR}/proxy_ssl_error.log
    CustomLog ${APACHE_LOG_DIR}/proxy_ssl_access.log combined
</VirtualHost>

<VirtualHost *:80>
    ServerName serverUbuntuServer
    
    ProxyRequests Off
    ProxyPreserveHost On

    # Specchiamo il Path Routing anche in chiaro, massima stabilità per i test!
    ProxyPass /blue http://192.168.56.20/blue
    ProxyPassReverse /blue http://192.168.56.20/blue

    ProxyPass /red http://192.168.56.30/red
    ProxyPassReverse /red http://192.168.56.30/red

    ErrorLog ${APACHE_LOG_DIR}/proxy_http_error.log
    CustomLog ${APACHE_LOG_DIR}/proxy_http_access.log combined
</VirtualHost>
EOF

# pulizia dei file 
a2dissite 000-default.conf
rm -f /etc/apache2/sites-enabled/000-default.conf
rm -f /var/www/html/index.html

a2ensite reverse-proxy.conf

# riavvio 
systemctl restart apache2
