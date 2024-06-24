#!/bin/bash

set -e

# Update and install required packages
dnf install -y bind bind-utils

# Generate RNDC key and store it in the synced folder
rndc-confgen -a -c /etc/rndc.key
chown named:named /etc/rndc.key

rndc_key=$(grep secret /etc/rndc.key | awk '{print $2}' | tr -d '";')

# Configure BIND for dynamic DNS updates
cat <<EOF > /etc/named.conf
options {
    directory "/var/named";
    dump-file "/var/named/data/cache_dump.db";
    statistics-file "/var/named/data/named_stats.txt";
    memstatistics-file "/var/named/data/named_mem_stats.txt";
    allow-query { any; };
    recursion yes;
    forwarders {
        8.8.8.8;
        8.8.4.4;
    };
    dnssec-validation auto;
};

# Define the RNDC key directly
key rndc-key {
    algorithm hmac-sha256;
    secret "$rndc_key";
};

controls {
    inet 127.0.0.1 allow { any; } keys { "rndc-key"; };
};

zone "db.local" {
    type master;
    file "/var/named/db.local";
    allow-update { key "rndc-key"; };
};

zone "1.168.192.in-addr.arpa" {
    type master;
    file "/var/named/db.192.168.1";
    allow-update { key "rndc-key"; };
};
EOF

# Create DNS zone files
cat <<EOF > /var/named/db.local
\$TTL 604800
@       IN      SOA     dns.db.local. root.db.local. (
                              2         ; Serial
                         604800         ; Refresh
                          86400         ; Retry
                        2419200         ; Expire
                         604800         ; Negative Cache TTL
);
@       IN      NS      dns.db.local.
@       IN      A       192.168.1.3
dns     IN      A       192.168.1.3

nginx   IN      A       192.168.4.3
nginx   IN      A       192.168.4.4
EOF

cat <<EOF > /var/named/db.192.168.1
\$TTL 604800
@       IN      SOA     dns.db.local. root.db.local. (
                              2         ; Serial
                         604800         ; Refresh
                          86400         ; Retry
                        2419200         ; Expire
                         604800         ; Negative Cache TTL
);
@       IN      NS      dns.db.local.
3       IN      PTR     dns.db.local.
EOF

# Set appropriate permissions
chown named:named /var/named/db.local
chown named:named /var/named/db.192.168.1

cp /etc/rndc.key /vagrant/
# Start and enable BIND service
systemctl enable named
systemctl start named

# Check BIND status
systemctl status named

echo "DNS server setup completed!"
