#!/bin/bash

# 检查是否支持运行整个脚本
if ! command -v bash >/dev/null 2>&1; then
    echo "Error: Bash is not installed or not in the system's PATH. Please install Bash and try again." >&2
    exit 1
fi

# 检查是否是root用户
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" >&2
   exit 1
fi

# 输入用户名并校验是否重复
while true; do
    read -p "Enter username: " username
    if [[ -z "$username" ]]; then
        echo "Username cannot be empty. Please try again."
    elif id "$username" >/dev/null 2>&1; then
        echo "Username '$username' already exists. Please choose a different username."
    elif [[ ! "$username" =~ ^[A-Za-z]+$ ]]; then
        echo "Username must contain only letters (both uppercase and lowercase). Please try again."
    else
        break
    fi
done

# 输入密码并校验
while true; do
    read -p "Enter password (press enter for a random password): " password
    if [[ -z "$password" ]]; then
        password=$(tr -dc 'A-HJ-NP-Za-km-z2-9!@#$%^&*_+=' < /dev/urandom | fold -w 12 | grep '[!@#$%^&*_+=]' | head -n 1)
        echo ">  $password"
        break
    elif [[ ${#password} -lt 12 || "$password" == "${password^^}" || "$password" == "${password,,}" || "$password" == "${password//[^0-9]/}" ]]; then
        echo "Password must be at least 12 characters long and contain a combination of uppercase letters, lowercase letters, and numbers. Please try again."
    else
        break
    fi
done

# 选择shell
while true; do
    echo "Available shells:"
    echo "1) /bin/bash"
    echo "2) /sbin/nologin"
    read -p "Choose a shell (default 2): " shell_choice
    if [[ -z "$shell_choice" || "$shell_choice" == "2" ]]; then
        user_shell="/sbin/nologin"
        break
    elif [[ "$shell_choice" == "1" ]]; then
        user_shell="/bin/bash"
        break
    else
        echo "Invalid choice. Please enter '1' or '2'."
    fi
done

# 设置主目录
read -p "Enter home directory (press enter for default): " home_dir
if [[ -z "$home_dir" ]]; then
    home_dir="/home/$username"
fi

# 创建用户并指定家目录
useradd -m -d "$home_dir" -s "$user_shell" "$username"

# 设置密码并且设置过期
echo "$username:$password" | chpasswd
chage -d 1 "$username"

# 设置 sudo 权限
while true; do
    read -p "Grant sudo privileges? (y/n, default n): " sudo_priv
    if [[ -z "$sudo_priv" || "$sudo_priv" == "n" ]]; then
        sudo_priv="no"
        break
    elif [[ "$sudo_priv" == "y" ]]; then
        usermod -aG sudo "$username"
        break
    else
        echo "Invalid input. Please enter 'y' or 'n'."
    fi
done

# 用户到期时间
read -p "Enter expiry days (press enter for no expiry): " expiry_days
if [[ -n "$expiry_days" ]]; then
    expiry_date=$(date -d "+$expiry_days days" +%Y-%m-%d)
    chage -E "$expiry_date" "$username"
fi

# 输入备注
while true; do
    read -p "Enter user comment (press enter for no comment): " comment
    if [[ -n "$comment" ]]; then
        if [[ ${#comment} -gt 64 ]]; then
            comment="${comment:0:64}"
        fi
        usermod -c "$comment" "$username"
        break
    else
        break
    fi
done

# 输出用户信息
echo "============ USER ACCOUNT INFO ==============="
echo "Username: $username"
echo "Password: $password"
echo "Sudo privileges: $sudo_priv"
echo "Shell: $user_shell"
echo "Home directory: $home_dir"
echo "Expiry days: $expiry_days"
echo "Comment: $comment"
echo "============ USER ACCOUNT INFO ==============="

# 是否保存用户信息到本地文件
read -p "Save user info to a local file? (y/n, default n): " save_to_file
if [[ "$save_to_file" == "y" ]]; then
    echo "Username: $username" > "user_info_$username.txt"
    echo "Password: $password" >> "user_info_$username.txt"
    echo "Sudo privileges: $sudo_priv" >> "user_info_$username.txt"
    echo "Shell: $user_shell" >> "user_info_$username.txt"
    echo "Home directory: $home_dir" >> "user_info_$username.txt"
    echo "Expiry days: $expiry_days" >> "user_info_$username.txt"
    echo "Comment: $comment" >> "user_info_$username.txt"
    echo "User info saved to user_info_$username.txt"
fi
