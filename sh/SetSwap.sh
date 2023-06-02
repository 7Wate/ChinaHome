#!/bin/bash

# Check if the script is being run as root
if [[ $EUID -ne 0 ]]; then
  echo "This script must be run as root."
  exit 1
fi

# Get swap size from user input
read -p "Enter the swap size (e.g., 2G, 4G): " swap_size

# Check if swap_size is valid
if [[ ! $swap_size =~ ^[0-9]+[G]$ ]]; then
  echo "Invalid swap size. Please enter a valid size, like 2G or 4G."
  exit 1
fi

# Create swap file
if ! fallocate -l $swap_size /swapfile; then
  echo "Failed to create swap file."
  exit 1
fi

# Set file permissions
chmod 600 /swapfile

# Format swap file
if ! mkswap /swapfile; then
  echo "Failed to format the swap file."
  exit 1
fi

# Enable swap
if ! swapon /swapfile; then
  echo "Failed to enable swap."
  exit 1
fi

# Add swap information to /etc/fstab file
echo "/swapfile swap swap defaults 0 0" >> /etc/fstab

if ! grep -q "^/swapfile swap swap defaults 0 0" /etc/fstab; then
  echo "Failed to write to /etc/fstab."
  exit 1
fi

echo "Swap cache successfully set to $swap_size"
