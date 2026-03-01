#! /bin/bash

NODE_VERSION=24
NPM_MIRROR=${NPM_MIRROR:-'https://registry.npmmirror.com'}

curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /usr/share/keyrings/nodesource.gpg
echo "deb [signed-by=/usr/share/keyrings/nodesource.gpg] https://deb.nodesource.com/node_${NODE_VERSION}.x nodistro main" | sudo tee /etc/apt/sources.list.d/nodesource.list
apt update -y && apt install -y nodejs

npm set registry -g "$NPM_MIRROR"