#!/bin/bash

echo "Please select the version of Python you want to install:"
echo "1. Python 3.11.3"
echo "2. Python 3.10.11"

read -p "Enter your choice (1 or 2): " choice

if [ "$choice" == "1" ]; then
    PYTHON_VERSION="3.11.3"
elif [ "$choice" == "2" ]; then
    PYTHON_VERSION="3.10.11"
else
    echo "Invalid input, exiting the program."
    exit 1
fi

echo "You have chosen to install Python version $PYTHON_VERSION."

# Check if curl is installed
if ! command -v curl &> /dev/null; then
    echo "curl could not be found, please install curl first."
    exit 1
fi

# Install dependencies for Linux
if [ "$(expr substr $(uname -s) 1 5)" == "Linux" ]; then
    echo "Installing dependencies for Linux."
    sudo apt-get update
    sudo apt-get install -y make build-essential libssl-dev zlib1g-dev libbz2-dev \
    libreadline-dev libsqlite3-dev wget curl llvm libncurses5-dev libncursesw5-dev \
    xz-utils tk-dev libffi-dev liblzma-dev python-openssl
fi

# Install Python
if [ "$(uname)" == "Darwin" ]; then
    # For macOS
    PYTHON_DOWNLOAD_URL="https://mirrors.tuna.tsinghua.edu.cn/python/$PYTHON_VERSION/python-$PYTHON_VERSION-macos11.pkg"
    curl -o python.pkg "$PYTHON_DOWNLOAD_URL"
    sudo installer -pkg python.pkg -target /
    rm python.pkg
elif [ "$(expr substr $(uname -s) 1 5)" == "Linux" ]; then
    # For Linux
    PYTHON_DOWNLOAD_URL="https://mirrors.tuna.tsinghua.edu.cn/python/$PYTHON_VERSION/Python-$PYTHON_VERSION.tar.xz"
    curl -o python.tar.xz "$PYTHON_DOWNLOAD_URL"
    tar -xf python.tar.xz
    cd Python-$PYTHON_VERSION
    ./configure --enable-optimizations
    make -j$(nproc)
    sudo make altinstall
    cd ..
    rm -rf Python-$PYTHON_VERSION python.tar.xz
else
    echo "Unsupported operating system."
    exit 1
fi

echo "Python $PYTHON_VERSION has been successfully installed."

# Update PATH
if [ "$(expr substr $(uname -s) 1 5)" == "Linux" ]; then
    echo "Updating PATH."
    echo "export PATH=/usr/local/bin:$PATH" >> ~/.bashrc
    source ~/.bashrc
fi

read -p "Do you want to install pip? (y/n): " install_pip

if [ "$install_pip" == "y" ]; then
    # Install pip
    curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py
    sudo python3.$PYTHON_VERSION get-pip.py
    rm get-pip.py
    echo "pip has been installed."
fi

read -p "Do you want to set up a mirror source for pip? (y/n): " set_mirror

if [ "$set_mirror" == "y" ]; then
    echo "Please select a mirror source:"
    echo "1. Tsinghua University (https://pypi.tuna.tsinghua.edu.cn/simple)"
    echo "2. Aliyun (https://mirrors.aliyun.com/pypi/simple)"
    echo "3. USTC (https://mirrors.ustc.edu.cn/pypi/web/simple)"

    read -p "Enter your choice (1, 2, or 3): " mirror_choice

    case $mirror_choice in
        1)
            mirror_source="https://pypi.tuna.tsinghua.edu.cn/simple"
            ;;
        2)
            mirror_source="https://mirrors.aliyun.com/pypi/simple"
            ;;
        3)
            mirror_source="https://mirrors.ustc.edu.cn/pypi/web/simple"
            ;;
        *)
            echo "Invalid input, using the default mirror source."
            mirror_source="https://pypi.org/simple"
            ;;
    esac

    pip_config_file="$HOME/.pip/pip.conf"
    mkdir -p "$HOME/.pip"
    echo "[global]" > "$pip_config_file"
    echo "index-url = $mirror_source" >> "$pip_config_file"
    echo "Mirrors source has been set to $mirror_source."
fi
