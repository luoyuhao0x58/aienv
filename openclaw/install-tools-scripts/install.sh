#! /bin/bash
set -uexo pipefail

apt-get update -y
for filename in $(ls ./*_*.sh | sort); do
  bash "$filename"
done
apt-get clean && rm -rf /var/lib/apt/lists/* && rm -rf /tmp/*