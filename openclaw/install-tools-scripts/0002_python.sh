#! /bin/bash

echo "[global]
index-url = ${PIP_MIRROR:-https://mirrors.aliyun.com/pypi/simple}
no-cache-dir = true" > /etc/pip.conf


apt install -y --no-install-recommends \
  python3-pip \
  python3 \
  python3-dev \
  python3-venv \
  pipx \
  python3-httpx

pipx install --global --system-site-packages uv huggingface_hub