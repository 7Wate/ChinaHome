#!/bin/bash
read -p "Please enter the proxy address(e.g 127.0.0.1:7890): " proxy_addr

echo "export http_proxy=http://$proxy_addr/" >> ~/.bashrc
echo "export https_proxy=http://$proxy_addr/" >> ~/.bashrc
echo "Proxy has been set successfully!"

exec bash
