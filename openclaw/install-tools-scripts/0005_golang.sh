#! /bin/bash

GOLANG_VERSION=1.26.1
ARCH=$(uname -m)
case $ARCH in
    x86_64)
        GO_ARCH="amd64"
        ;;
    aarch64|arm64)
        GO_ARCH="arm64"
        ;;
    *)
        exit
        ;;
esac


target_file="go$GOLANG_VERSION.linux-$GO_ARCH.tar.gz"
wget "https://golang.google.cn/dl/$target_file"

tar -C /usr/local -xzf "$target_file"
rm -rf "$target_file"

echo 'export PATH=$PATH:/usr/local/go/bin' >> /etc/bash.bashrc
echo "export GOPROXY=${GOPROXY:-'https://goproxy.io,direct'}" >> /etc/bash.bashrc