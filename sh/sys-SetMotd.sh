#!/bin/bash

# Ensure the script is being run as root
if [ "$(id -u)" -ne 0 ]; then
    echo -e ">>>>>>> \e[1;31mError: This script must be run as root!\e[0m"
    exit 1
fi

# Function to display system information and save it to /etc/motd
function set_motd {
    echo "" > /etc/motd
    echo -e "\e[1;34mHost:\e[0m $HOSTNAME" >> /etc/motd
    echo -e "\e[1;34mTime:\e[0m $TIME" >> /etc/motd
    echo -e "\e[1;34mSystem:\e[0m $SYS_VERSION" >> /etc/motd
    echo -e "\e[1;34mKernel:\e[0m $KERNEL_VERSION" >> /etc/motd
    echo -e "\e[1;34mUptime:\e[0m $UPTIME" >> /etc/motd
    echo -e "\e[1;34mNetwork:\e[0m" >> /etc/motd
    ip -o -4 addr show | awk '{print $2, $4}' >> /etc/motd
    if [ -n "$custom_info" ]; then
        echo -e "\n\e[1;31mInformation:\e[0m" >> /etc/motd
        echo -e "\e[1;31m$custom_info\e[0m" >> /etc/motd
    fi
    echo "" >> /etc/motd
}

# Prompt user to enter custom information
read -p ">>>>>>> Please enter your custom information: " -e custom_info

# Check if /etc/motd file exists and is writable
if [ ! -w "/etc/motd" ]; then
    echo -e ">>>>>>> \e[1;31mError: Cannot write to /etc/motd file. Please make sure you have sufficient permissions to run this script!\e[0m"
    exit 1
fi

# Backup the original /etc/motd file with the current date in the filename
backup_filename="/etc/motd.bak.$(date '+%Y%m%d')"
cp /etc/motd "$backup_filename"

# Set system information variables
HOSTNAME=$(hostname)
TIME=$(date)
SYS_VERSION=$(lsb_release -ds 2>/dev/null || echo "N/A")
KERNEL_VERSION=$(uname -r)
UPTIME=$(uptime -p)

# Call the function to set motd with the custom information
set_motd

echo -e "\n>>>>>>> \e[1;32mSetup successful!\e[0m\n"
cat /etc/motd
