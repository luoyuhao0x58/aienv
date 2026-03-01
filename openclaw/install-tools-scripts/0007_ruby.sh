#! /bin/bash

apt install -y ruby
gem sources --remove "$(gem sources | tail -n 1)"
gem sources -a "$MIRROR_RUBY_GEM"