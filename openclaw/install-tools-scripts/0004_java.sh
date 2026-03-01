#! /bin/bash

JAVA_VERSION=25

apt install -y wget gnupg
wget -q -O - https://download.bell-sw.com/pki/GPG-KEY-bellsoft | sudo gpg --dearmor -o /usr/share/keyrings/bellsoft-archive-keyring.gpg

ARCH=$(dpkg --print-architecture)

echo "deb [arch=$ARCH signed-by=/usr/share/keyrings/bellsoft-archive-keyring.gpg] https://apt.bell-sw.com/ stable main" | sudo tee /etc/apt/sources.list.d/bellsoft.list

sudo apt update
sudo apt install -y "bellsoft-java$JAVA_VERSION"