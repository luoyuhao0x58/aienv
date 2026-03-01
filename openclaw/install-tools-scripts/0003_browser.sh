#! /bin/bash

apt install -y chromium

npm install -g playwright-core

mkdir -p $PLAYWRIGHT_BROWSERS_PATH
chown -R ${USER_NAME} $PLAYWRIGHT_BROWSERS_PATH
/usr/lib/node_modules/playwright-core/cli.js install-deps
sudo -u ${USER_NAME} --preserve-env=PLAYWRIGHT_BROWSERS_PATH bash -c "/usr/lib/node_modules/playwright-core/cli.js install chromium"