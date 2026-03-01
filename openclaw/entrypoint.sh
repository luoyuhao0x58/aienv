#! /bin/bash

if [ ! -f ~/.openclaw/openclaw.json ]; then
  cp -r /.openclaw/init-data/* ~/.openclaw/
  rm -rf /.openclaw/init-data
  chmod 700 ~/.openclaw
  mkdir -p "$NODE_COMPILE_CACHE"

  clawhub login --token "$CLAWHUB_TOKEN"
  if [ -n "$CLAWHUB_TOKEN" ]; then
    clawhub install web-search-plus
    clawhub install beauty-generation-api
    clawhub install edge-tts
    clawhub install self-improving
  fi

  truncate -s 0 ~/.bash_history
fi

exec supervisord -n