#!/bin/bash

url1="https://9i5.top/sh/ChangeMirrors.sh"
url2="https://gitee.com/SuperManito/LinuxMirrors/raw/main/ChangeMirrors.sh"

file1=$(curl -sSL $url1)
file2=$(curl -sSL $url2)

if [ "$file1" != "$file2" ]; then
    echo "The contents of the ChangeMirrors are different, please update"
else
    echo "The contents of the ChangeMirrors are the same"
fi


url1="https://9i5.top/sh/DockerInstallation.sh"
url2="https://gitee.com/SuperManito/LinuxMirrors/raw/main/DockerInstallation.sh)"

file1=$(curl -sSL $url1)
file2=$(curl -sSL $url2)

if [ "$file1" != "$file2" ]; then
    echo "The contents of the DockerInstallation are different, please update"
else
    echo "The contents of the DockerInstallation are the same"
fi
