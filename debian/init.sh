#!/bin/bash

# Set the hostname
read -p "Enter the desired hostname: " hostname
hostnamectl set-hostname $hostname

# Set the FQDN
read -p "Enter the desired fully qualified domain name: " fqdn
echo "$fqdn" > /etc/hostname

# List available network interfaces
interfaces=$(ls /sys/class/net | awk '{print $1}')

# Prompt the user to select a network interface
echo "Available network interfaces:"
for interface in $interfaces; do
  echo " - $interface"
done

read -p "Enter the name of the network interface you want to configure: " selected_interface

# Verify that the selected interface is valid
if ! [[ $interfaces =~ (^|[[:space:]])$selected_interface($|[[:space:]]) ]]; then
  echo "Error: Invalid interface name"
  exit 1
fi

# Prompt the user to enter network configuration information
read -p "Enter the desired IP address for $selected_interface: " ip_address
read -p "Enter the desired netmask for $selected_interface: " netmask
read -p "Enter the desired gateway for $selected_interface: " gateway
read -p "Enter the desired DNS server(s) for $selected_interface (separated by spaces): " dns_servers

# Update the network configuration for the selected interface
cat << EOF > /etc/network/interfaces.d/$selected_interface.cfg
auto $selected_interface
iface $selected_interface inet static
  address $ip_address
  netmask $netmask
  gateway $gateway
  dns-nameservers $dns_servers
EOF

# Restart the networking service to apply the changes
systemctl restart networking.service

echo "Network configuration updated successfully for $selected_interface"
