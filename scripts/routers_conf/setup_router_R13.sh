#!/bin/bash

# Enable IP forwarding
sysctl -w net.ipv4.ip_forward=1

# Ensure IP forwarding persists across reboots
cat <<EOT >> /etc/sysctl.conf
net.ipv4.ip_forward=1
EOT

# Install and configure DHCP relay
export DEBIAN_FRONTEND=noninteractive
apt-get update -yq
apt-get install -yq isc-dhcp-relay

cat <<EOT > /etc/default/isc-dhcp-relay
SERVERS="192.168.1.2"
INTERFACES="eth1 eth2"
OPTIONS=""
EOT

# Configure network interface eth2 with the IP address 192.168.3.1 using netplan
cat <<EOT > /etc/netplan/01-netcfg.yaml
network:
  version: 2
  ethernets:
    eth1:
      dhcp4: true
      routes:
        - to: 192.168.2.0/27
          via: 192.168.1.4
          on-link: true
        - to: 192.168.4.0/29
          via: 192.168.1.6
          on-link: true
    eth2:
      addresses:
        - 192.168.3.1/29
EOT

chmod 600 /etc/netplan/*
# Apply the netplan configuration
netplan apply

# Restart DHCP relay service
systemctl restart isc-dhcp-relay

# Enable services to start on boot
systemctl enable isc-dhcp-relay
systemctl enable systemd-networkd

# Check status of DHCP relay
systemctl status isc-dhcp-relay

echo "Router R1 setup completed!"
