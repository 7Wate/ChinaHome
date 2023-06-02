#!/bin/bash

if [ "$EUID" -ne 0 ]; then
    echo "Please run as root or use sudo"
    exit
fi

command -v curl >/dev/null 2>&1 || { echo >&2 "curl is not installed, please install it and try again."; exit 1; }

echo "Please select the operation:"
echo "0. System Status"
echo "1. Change Mirrors"
echo "2. Install Docker"
echo "3. Set Proxy"
echo "4. Set Swap"
echo "5. New User"
read -p "Enter your choice: " choice

case $choice in
    0)
        bash <(curl -sSL https://9i5.top/sh/SystemStatus.sh)
        ;;
    1)
        bash <(curl -sSL https://9i5.top/sh/ChangeMirrors.sh)
        ;;
    2)
        bash <(curl -sSL https://9i5.top/sh/DockerInstallation.sh)
        ;;
    3)
        bash <(curl -sSL https://9i5.top/sh/SetPorxy.sh)
        ;;
    4)
        bash <(curl -sSL https://9i5.top/sh/SetSwap.sh)
        ;;
    5)
        bash <(curl -sSL https://9i5.top/sh/NewUser.sh)
        ;;
    *)
        echo "Invalid choice, exit"
        exit
        ;;
esac
