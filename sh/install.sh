#!/bin/bash

# Make sure the script is run as root
if [ "$EUID" -ne 0 ]; then
    echo "Please run as root or use sudo."
    exit 1
fi

# Check if curl is installed
if ! command -v curl >/dev/null 2>&1; then
    echo "curl is not installed, please install it and try again."
    exit 1
fi

# Function to execute the chosen operation
execute_operation() {
    local operation_script=$1

    # Check if the operation_script variable is not empty
    if [ -z "$operation_script" ]; then
        echo "Invalid operation, exiting the program."
        exit 1
    fi

    # Execute the chosen operation
    bash <(curl -sSL "https://9i5.top/sh/${operation_script}.sh")
}

echo "Please select the operation:"
echo "0. Docker"
echo "1. Python"
echo "2. Node"

read -p "Enter your choice (0-2): " choice

# Execute the chosen operation
case $choice in
    0)
        execute_operation "install-Docker"
        ;;
    1)
        execute_operation "install-Python"
        ;;
    2)
        execute_operation "install-Node"
        ;;
    *)
        echo "Invalid choice, exiting the program."
        exit 1
        ;;
esac
