#! /bin/bash
set -uexo pipefail

export TZ='Asia/Hong_Kong'
export MIRROR_APT='mirrors.aliyun.com'

# change mirror
sed -i "s/deb.debian.org/${MIRROR_APT}/g" /etc/apt/sources.list.d/debian.sources
sed -i 's/Components: main/Components: main contrib non-free/g' /etc/apt/sources.list.d/debian.sources
apt-get update -y
apt-get install -y tzdata locales
apt-get upgrade -y

# locale setting
echo 'en_US ISO-8859-1
en_US.UTF-8 UTF-8' > /etc/locale.gen && locale-gen
echo 'export LANG=en_US.UTF-8
export LC_MESSAGES=en_US' > /etc/profile.d/locale.sh
echo "LANG='en_US.UTF-8'" >>/etc/default/locale

# change timezone
ln -fs /usr/share/zoneinfo/$TZ /etc/localtime
dpkg-reconfigure locales tzdata

# change sh
ln -sf /bin/bash /bin/sh

# install base package
PKG_LIST="sudo wget vim-tiny mtr-tiny telnet less p7zip-full file tree \
iputils-ping netcat-traditional lsof procps gnupg gnupg2 pinentry-tty \
iproute2 net-tools dnsutils rsync curl screen git jq"
apt-get install -y $PKG_LIST
update-ca-certificates --fresh

# history setting
sed -r -i -e '/^[[:space:]]*(HISTFILESIZE|HISTCONTROL|HISTSIZE|HISTTIMEFORMAT)=/d' /etc/skel/.bashrc
echo 'export HISTFILESIZE=100000
export HISTCONTROL=ignoredups
export HISTSIZE=10000
export HISTTIMEFORMAT="[%Y-%m-%d %H:%M:%S]  "' > /etc/profile.d/history.sh

# limits setting
echo '*               soft    nofile          65535
*               hard    nofile          65535
root            soft    nofile          65535
root            hard    nofile          65535
root            soft    core            unlimited
root            hard    core            unlimited' > /etc/security/limits.conf

# editor setting
update-alternatives --set editor /usr/bin/vim.tiny >/dev/null
ln -s /usr/bin/vi /usr/bin/vim
echo 'runtime! debian.vim
set nocompatible
set background=dark
set laststatus=2
set showmode
set tabstop=4
set shiftwidth=4
set softtabstop=4
set expandtab
set mouse=""
set nobackup
set backspace=indent,eol,start' > /etc/vim/vimrc.local
rm /etc/cron.daily/*

# create runtime user
export USER_ID=${USER_ID:-"1000"}
export GROUP_ID=${GROUP_ID:-$USER_ID}
export USER_NAME=${USER_NAME:-"openclaw"}
export USER_HOME=${USER_HOME:-"/home/$USER_NAME"}
echo "$USER_NAME ALL=(ALL) NOPASSWD: /usr/bin/apt-get, /usr/bin/apt" >> /etc/sudoers
groupadd -g $GROUP_ID $USER_NAME
useradd -d $USER_HOME -s /bin/bash -N -m -u $USER_ID -g $GROUP_ID $USER_NAME

./install-nodejs.sh
./install-openclaw.sh
./install-supervisor.sh

mkdir /.openclaw
chown -R ${USER_NAME}:${USER_NAME} /.openclaw
sudo -u ${USER_NAME} bash -c "mkdir -p $USER_HOME/.openclaw"
apt-get clean && rm -rf /var/lib/apt/lists/* && rm -rf /tmp/*