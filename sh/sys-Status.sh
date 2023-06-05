#!/bin/bash

# 获取系统信息
HOSTNAME=$(hostname)
TIME=$(date)
if [ -x "$(command -v lsb_release)" ]; then
    SYS_VERSION=$(lsb_release -d | cut -d ':' -f 2- | sed 's/^\s*//')
else
    SYS_VERSION=$(cat /etc/*-release | grep PRETTY_NAME | cut -d '=' -f 2- | tr -d '"')
fi
KERNEL_VERSION=$(uname -r)
UPTIME=$(uptime -p)
LOAD_AVERAGE=$(uptime | awk -F'[a-z]:' '{ print $2 }')
DISK_USAGE=$(df -h --total | awk '/total/ {print $3 " used, " $5 " used"}')

# 输出系统信息
echo "====================================================="
echo "Host: $HOSTNAME"
echo "Time: $TIME"
echo "System: $SYS_VERSION"
echo "Kernel: $KERNEL_VERSION"
echo "Uptime: $UPTIME"
echo "Load Average: $LOAD_AVERAGE"
echo "Disk Usage: $DISK_USAGE"
echo "====================================================="

# 检查 CPU 使用率
echo "CPU Load: $(uptime)"
echo "Top 5 CPU Consuming Processes:"
echo "-----------------------------------------------------"
ps -eo pid,ppid,cmd,%cpu --sort=-%cpu | head -n 6
echo "-----------------------------------------------------"

# 检查内存使用
echo "Memory Usage:"
echo "-----------------------------------------------------"
free -h
echo "-----------------------------------------------------"

# 检查网络连接
echo "Active Network Connections:"
echo "-----------------------------------------------------"
if [ -x "$(command -v netstat)" ]; then
    netstat -tunlp
elif [ -x "$(command -v ss)" ]; then
    ss -tunlp
else
    echo "Cannot find command 'netstat' or 'ss' to show network connections."
fi
echo "-----------------------------------------------------"

# 用户列表（非系统用户，可远程登录，UID > 1000）
echo "User List (Non-System Users, Remote Login, UID > 1000):"
echo "-----------------------------------------------------"
awk -F: '($3 >= 1000) && ($7 != "/sbin/nologin") {print $1}' /etc/passwd
echo "-----------------------------------------------------"

exit 0
