#!/bin/bash

# Check if the script is being run as root
if [[ $EUID -ne 0 ]]; then
  echo "This script must be run as root."
  exit 1
fi

# Check if iptables is installed
if ! command -v iptables >/dev/null 2>&1; then
    echo "iptables is not installed, please install it and try again."
    exit 1
fi

# Check if netfilter-persistent is installed
if ! command -v netfilter-persistent >/dev/null 2>&1; then
    echo "netfilter-persistent is not installed, please install it and try again."
    exit 1
fi

# Function to validate IP address
function validate_ip_address {
    local ip_address=${1%/*}
    local subnet=${1#*/}
    if [[ ! $ip_address =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}$ ]]; then
        echo "Invalid IP address format. Please enter a valid IP address."
        return 1
    fi

    IFS='.' read -ra octets <<< "$ip_address"
    for octet in "${octets[@]}"; do
        if [[ $octet -lt 0 || $octet -gt 255 ]]; then
            echo "Invalid IP address: $ip_address"
            return 1
        fi
    done

    if [[ $subnet != $ip_address && ( ! $subnet =~ ^[0-9]+$ || $subnet -lt 0 || $subnet -gt 32 ) ]]; then
        echo "Invalid subnet: $subnet. Please enter a valid subnet (0-32)."
        return 1
    fi

    return 0
}

# Function to validate port
function validate_port {
    local port=$1
    if ! [[ $port =~ ^[0-9]+$ ]] || ((port < 1 || port > 65535)); then
        echo "Invalid port number: $port. Please enter a valid port number (1-65535)."
        return 1
    fi

    return 0
}

# Function to validate protocol
function validate_protocol {
    local protocol=$1
    if [[ $protocol != "tcp" && $protocol != "udp" && $protocol != "all" ]]; then
        echo "Invalid protocol: $protocol. Please enter 'tcp', 'udp', or 'all'."
        return 1
    fi

    return 0
}

# Function to validate policy
function validate_policy {
    local policy=$1
    if [[ $policy != "ACCEPT" && $policy != "REJECT" && $policy != "DROP" ]]; then
        echo "Invalid policy: $policy. Please enter 'ACCEPT', 'REJECT', or 'DROP'."
        return 1
    fi

    return 0
}

# Function to save iptables rules permanently
function save_rules {
    read -p "Do you want to save these changes permanently? (y/n): " save
    if [[ "$save" == "y" || "$save" == "Y" ]]; then
        if ! command -v iptables-save >/dev/null 2>&1; then
            echo "iptables-save command not found. Please install iptables-persistent package and try again."
            exit 1
        fi
        iptables-save && echo "The changes have been saved permanently." || echo "Unable to save rules. Please check if you have write permissions to '/etc/iptables/rules.v4'."
    fi
}

while true; do
    echo "Please select the operation:"
    echo "1. List rules"
    echo "2. Block IP address"
    echo "3. Unblock IP address"
    echo "4. Open firewall"
    echo "5. Close firewall"
    echo "6. Quick manage: Default"
    echo "7. Quick manage: Web service"
    echo "8. Custom manage"
    echo "9. Exit"

    read -p "Enter your choice (1-9): " choice

    case $choice in
        1)
            echo "====================================================="
            echo "Listing iptables rules..."
            echo "-----------------------------------------------------"
            iptables -L -v -n
            echo "====================================================="
            ;;
        2)
            read -p "Enter the IP address to block (0.0.0.0 to block all): " ip_address
            if [[ -n $ip_address && $ip_address != "0.0.0.0" ]]; then
                if ! validate_ip_address "$ip_address"; then
                    continue
                fi
            fi
            echo "Blocking IP address: $ip_address..."
            iptables -A INPUT -s $ip_address -j DROP
            save_rules
            ;;
        3)
            read -p "Enter the IP address to unblock: " ip_address
            if ! validate_ip_address "$ip_address"; then
                continue
            fi
            echo "Unblocking IP address: $ip_address..."
            iptables -D INPUT -s $ip_address -j DROP
            save_rules
            ;;
        4)
            echo "Opening firewall..."
            iptables -P INPUT ACCEPT
            iptables -P OUTPUT ACCEPT
            iptables -P FORWARD ACCEPT
            iptables -F
            save_rules
            ;;
        5)
            echo "Closing firewall..."
            iptables -P INPUT DROP
            iptables -P OUTPUT DROP
            iptables -P FORWARD DROP
            iptables -F
            save_rules
            ;;
        6)
            echo "Setting default policy..."
            iptables -F
            iptables -P INPUT ACCEPT
            iptables -P OUTPUT ACCEPT
            iptables -P FORWARD ACCEPT
            iptables -A INPUT -p tcp --dport 22 -j ACCEPT
            save_rules
            ;;
        7)
            echo "Setting web service policy..."
            iptables -F
            iptables -P INPUT DROP
            iptables -P OUTPUT ACCEPT
            iptables -P FORWARD DROP
            iptables -A INPUT -p tcp --dport 22 -j ACCEPT
            iptables -A INPUT -p tcp --dport 80 -j ACCEPT
            iptables -A INPUT -p tcp --dport 443 -j ACCEPT
            iptables -A INPUT -p icmp --icmp-type echo-request -j ACCEPT
            save_rules
            ;;
        8)
            read -p "Enter the IP address (0.0.0.0 to match all): " ip_address
            if [[ -n $ip_address && $ip_address != "0.0.0.0" ]]; then
                if ! validate_ip_address "$ip_address"; then
                    continue
                fi
            fi

            read -p "Enter the port: " port
            if ! validate_port "$port"; then
                continue
            fi

            read -p "Enter the protocol (tcp, udp, all): " protocol
            if ! validate_protocol "$protocol"; then
                continue
            fi

            read -p "Enter the policy (ACCEPT/REJECT/DROP): " policy
            if ! validate_policy "$policy"; then
                continue
            fi

            if [ "$protocol" = "all" ]; then
                iptables -A INPUT -s $ip_address -p tcp --dport $port -j $policy
                iptables -A INPUT -s $ip_address -p udp --dport $port -j $policy
            else
                iptables -A INPUT -s $ip_address -p $protocol --dport $port -j $policy
            fi
            save_rules
            ;;
        9)
            echo "Exiting the program."
            exit 0
            ;;
        *)
            echo "Invalid choice. Please enter a valid option."
            ;;
    esac
done
