#!/bin/bash

if [ "$EUID" -ne 0 ]; then
    echo "Please run as root or use sudo"
    exit
fi

command -v curl >/dev/null 2>&1 || { echo >&2 "curl is not installed, please install it and try again."; exit 1; }

echo "Please select the operation:"
echo "1. Set proxy"
echo "2. Change mirrors"
echo "3. Install Docker"
read -p "Enter your choice: " choice

case $choice in
    1)
        bash <(curl -sSL https://9i5.top/sh/SetPorxy.sh)
        ;;
    2)
        bash <(curl -sSL https://9i5.top/sh/ChangeMirrors.sh)
        ;;
    3)
        bash <(curl -sSL https://9i5.top/sh/DockerInstallation.sh)
        ;;
    *)
        echo "Invalid choice, exit"
        exit
        ;;
esac
