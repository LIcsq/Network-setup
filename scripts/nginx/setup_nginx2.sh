#!/bin/bash

set -e

# Install Nginx and required packages
dnf install -y nginx lynx

# Create the directory for the website content if it doesn't exist
mkdir -p /var/www/html

# Copy the resume content from /vagrant/nginx_content to /var/www/html
cp -r /vagrant/nginx_content.html /var/www/html/

# Set the appropriate permissions for the directory and files
chown -R nginx:nginx /var/www/html
chmod -R 755 /var/www/html

# Create the Nginx configuration file
cat <<EOT > /etc/nginx/conf.d/default.conf
server {
    listen 80 default_server;
    listen [::]:80 default_server;

    root /var/www/html;
    index nginx_content.html;

    server_name nginx1;

    location / {
        try_files \$uri \$uri/ =404;
    }
}
EOT

# Test the Nginx configuration for any errors
nginx -t

# Enable and restart the Nginx service to apply the changes
systemctl enable nginx
systemctl restart nginx

echo "Nginx server setup completed and your resume is deployed!"
