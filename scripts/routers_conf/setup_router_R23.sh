#!/bin/bash

# Enable IP forwarding
echo 1 > /proc/sys/net/ipv4/ip_forward
sysctl -w net.ipv4.ip_forward=1

# Delete the default NAT route
ip route del default

# Install and configure DHCP relay
apt-get update
apt-get install -y isc-dhcp-relay
echo 'SERVERS="192.168.3.2"' > /etc/default/isc-dhcp-relay
echo 'INTERFACES="eth0 eth1"' >> /etc/default/isc-dhcp-relay
echo 'OPTIONS=""' >> /etc/default/isc-dhcp-relay
systemctl restart isc-dhcp-relay

# Configure static routes
ip route add 192.168.1.0/29 via 192.168.3.1
ip route add 192.168.4.0/24 via 192.168.3.1

# Save routes to persist across reboots
cat <<EOT >> /etc/network/interfaces
up route add -net 192.168.1.0/29 gw 192.168.3.1
up route add -net 192.168.4.0/24 gw 192.168.3.1
EOT

# Restart networking
systemctl restart networking
