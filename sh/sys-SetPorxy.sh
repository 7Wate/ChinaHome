#!/bin/bash

# 提示用户输入代理地址
read -p "Please enter the proxy address (e.g., 127.0.0.1:7890): " proxy_addr

# 检查是否输入了代理地址
if [[ -z $proxy_addr ]]; then
    echo "Proxy address is empty. Exiting..."
    exit 1
fi

# 这里我们不做复杂的代理地址格式检查，因为地址可以是IPv4, IPv6或者主机名。

# 删除旧的代理设置
sed -i '/http_proxy/d' ~/.bashrc
sed -i '/https_proxy/d' ~/.bashrc

# 设置代理环境变量
echo "export http_proxy=http://$proxy_addr/" >> ~/.bashrc
echo "export https_proxy=http://$proxy_addr/" >> ~/.bashrc

# 重新加载 bash 配置文件
if [[ -n $BASH_VERSION ]]; then
    source ~/.bashrc
    echo "Proxy has been set successfully!"
else
    echo "BASH is not available. Please manually reload your shell configuration to apply the proxy settings."
fi

exit 0
