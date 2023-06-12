#!/bin/bash

# Function to list non-system users with remote login capability
list_users() {
  echo "Non-system users with remote login capability and locked status:"
  echo "--------------------------------------------------------------"
  echo "Username        UID         Remote Login     Locked Status"
  echo "--------------------------------------------------------------"
  while IFS=: read -r username _ uid _ _ _ shell; do
    if [[ $uid -ge 1000 ]]; then
      if [[ $shell == "/usr/sbin/nologin" || $shell == "/bin/false" ]]; then
        remote_login="No"
      else
        remote_login="Yes"
      fi
      
      passwd_status=$(passwd -S "$username" | awk '{print $2}')
      if [[ $passwd_status == "L" ]]; then
        locked_status="Yes"
      else
        locked_status="No"
      fi
      
      printf "%-15s %-11s %-16s %s\n" "$username" "$uid" "$remote_login" "$locked_status"
    fi
  done < /etc/passwd
  echo "--------------------------------------------------------------"
}


# Function to disable remote login for root user
disable_root_login() {
  sed -i 's/^PermitRootLogin yes/PermitRootLogin no/' /etc/ssh/sshd_config
  service ssh restart
  echo "Remote login for root user has been disabled."
}

# Function to disable login for a specified user
disable_user_login() {
  read -p "Enter the username to disable login: " username
  if id "$username" >/dev/null 2>&1; then
    usermod -L "$username"
    echo "Login has been disabled for user $username."
  else
    echo "User $username does not exist."
  fi
}

# Function to enable remote login for a specified user
enable_user_login() {
  read -p "Enter the username to enable remote login: " username
  if id "$username" >/dev/null 2>&1; then
    usermod -U "$username"
    echo "Remote login has been enabled for user $username."
  else
    echo "User $username does not exist."
  fi
}

# Main script
while true; do
  echo "==========================================="
  echo "                Shell Menu"
  echo "-------------------------------------------"
  echo "1. List Users"
  echo "2. Disable Remote Login for Root"
  echo "3. Disable Remote Login for User"
  echo "4. Enable Remote Login for User"
  echo "5. Quit"
  echo "==========================================="
  read -p "Enter your choice: " choice
  echo

  case $choice in
    1)
      list_users
      ;;
    2)
      disable_root_login
      ;;
    3)
      disable_user_login
      ;;
    4)
      enable_user_login
      ;;
    5)
      echo "Exiting..."
      break
      ;;
    *)
      echo "Invalid choice. Please try again."
      ;;
  esac

  echo
done

