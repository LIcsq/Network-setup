#!/bin/bash

set -e

# Update package list and install Nginx
apt-get update -y
apt-get install -y nginx

# Create the directory for the website content if it doesn't exist
mkdir -p /var/www/html

# Copy the resume content from /vagrant/nginx_content to /var/www/html
cp -r /vagrant/nginx_content/* /var/www/html/

# Set the appropriate permissions for the directory and files
chown -R www-data:www-data /var/www/html
chmod -R 755 /var/www/html

# Ensure Nginx user has execute permissions on /var/www and /var directories
chmod 755 /var/www
chmod 755 /var

# Create the Nginx configuration file
cat <<EOT > /etc/nginx/sites-available/default
server {
    listen 80 default_server;
    listen [::]:80 default_server;

    root /var/www/html;
    index index.html;

    server_name _;

    location / {
        try_files \$uri \$uri/ =404;
    }

    error_page 403 404 /404.html;
    location = /404.html {
        internal;
    }
}
EOT

# Test the Nginx configuration for any errors
nginx -t

# Restart the Nginx service to apply the changes
systemctl restart nginx

echo "Nginx server setup completed and your resume is deployed!"
