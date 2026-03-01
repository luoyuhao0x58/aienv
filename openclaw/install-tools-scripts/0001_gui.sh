#! /bin/bash

apt install -y \
  fontconfig \
  fonts-noto-cjk \
  fonts-noto-cjk-extra \
  fonts-noto-color-emoji \
  && fc-cache -fv