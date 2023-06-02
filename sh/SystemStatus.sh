#!/bin/bash

# 获取系统信息
HOSTNAME=$(hostname)
TIME=$(date)
SYS_VERSION=$(cat /etc/*-release | grep PRETTY_NAME | cut -d '=' -f 2- | tr -d '"')
KERNEL_VERSION=$(uname -r)
UPTIME=$(uptime -p)
LOAD_AVERAGE=$(cat /proc/loadavg | awk '{print $1, $2, $3}')
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
echo "-------------------------------------"

# 检查内存使用
echo "Memory Usage:"
echo "-----------------------------------------------------"
free -h
echo "-----------------------------------------------------"

# 检查网络连接
echo "Active Network Connections:"
echo "-----------------------------------------------------"
netstat -tunlp
echo "-----------------------------------------------------"

# 用户列表（非系统用户，可远程登录，UID > 1000）
echo "User List (Non-System Users, Remote Login, UID > 1000):"
echo "-----------------------------------------------------"
awk -F: '($3 >= 1000) && ($7 != "/sbin/nologin") {print $1}' /etc/passwd
echo "-----------------------------------------------------"

exit 0
