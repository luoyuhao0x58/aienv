#! /bin/bash

OPENCLAW_VERSION=${OPENCLAW_VERSION:-"latest"}

# 安装openclaw
npm install -g "openclaw@$OPENCLAW_VERSION"
npm i -g clawhub