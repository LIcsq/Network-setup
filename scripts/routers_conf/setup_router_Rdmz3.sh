#!/bin/bash

# Enable IP forwarding
echo 1 > /proc/sys/net/ipv4/ip_forward
sysctl -w net.ipv4.ip_forward=1

# Delete the default NAT route
ip route del default

# Configure DHCP relay
cat <<EOT > /etc/default/isc-dhcp-relay
SERVERS="192.168.1.2"
INTERFACES="eth1 eth2"
OPTIONS=""
EOT

# Configure network interfaces using netplan
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
        - to: 192.168.3.0/29
          via: 192.168.1.5
          on-link: true
    eth2:
      addresses:
        - 192.168.4.1/29
EOT

# Apply netplan configuration
netplan apply

# Configure iptables for SNAT and DNAT
iptables -A INPUT -s 192.168.1.0/24 -d 192.168.4.0/29 -j ACCEPT
iptables -A FORWARD -s 192.168.4.0/29 -d 192.168.2.0/24 -j REJECT
iptables -A FORWARD -s 192.168.4.0/29 -d 192.168.3.0/24 -j REJECT
iptables -A FORWARD -d 192.168.4.0/29 -p tcp --dport 80 -m conntrack --ctstate NEW,ESTABLISHED -j ACCEPT
iptables -A FORWARD -d 192.168.4.0/29 -p tcp --dport 443 -m conntrack --ctstate NEW,ESTABLISHED -j ACCEPT
iptables -A FORWARD -s 192.168.4.0/29 -d 192.168.1.3 -p udp --dport 53 -j ACCEPT
iptables -A FORWARD -s 192.168.4.0/29 -d 192.168.1.2 -p udp --dport 68 -j ACCEPT
iptables -A FORWARD -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT

# Save iptables rules to persist across reboots
apt-get install -y iptables-persistent
netfilter-persistent save

# Restart DHCP relay service
systemctl restart isc-dhcp-relay

# Configure static routes
ip route add 192.168.1.0/29 via 192.168.3.1
ip route add 192.168.2.0/27 via 192.168.3.1

# Save routes to persist across reboots
cat <<EOT >> /etc/network/interfaces
up route add -net 192.168.1.0/29 gw 192.168.3.1
up route add -net 192.168.2.0/27 gw 192.168.3.1
EOT

# Restart networking
systemctl restart networking
