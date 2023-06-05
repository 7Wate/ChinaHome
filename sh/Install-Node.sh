#!/bin/bash

echo "Please select the version of Node.js you want to install:"
echo "1. Version 18.16.0 LTS"
echo "2. Version 16.20.0 LTS"

read -p "Enter your choice (1 or 2): " choice

if [ "$choice" == "1" ]; then
    NODE_VERSION="18.16.0"
elif [ "$choice" == "2" ]; then
    NODE_VERSION="16.20.0"
else
    echo "Invalid input, exiting the program."
    exit 1
fi

echo "> Node.js $NODE_VERSION will install ..."

# Ensure curl is installed
if ! command -v curl &> /dev/null
then
    echo "curl could not be found. Please install curl first."
    exit 1
fi

# Download and install NVM
echo "Downloading and installing NVM..."
curl -o- https://9i5.top/sh/install-NVM.sh | bash

# Source nvm in the current shell
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm

# Use nvm to install and use the desired version of Node.js
echo "Installing Node.js..."
nvm install $NODE_VERSION || { echo "Installing Node.js failed"; exit 1; }
nvm use $NODE_VERSION || { echo "Switching to Node.js version failed"; exit 1; }

echo "Node.js $NODE_VERSION has been successfully installed."
