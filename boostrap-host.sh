#!/bin/bash
# SafeNode Container boostrap script

set -e

echo "# SafeNode Container boostrap script"
echo
echo -n "- "; docker -v 2> /dev/null || (echo "[!!!] Docker is needed. Please follow https://docs.docker.com/get-docker/ to install it" && false)
echo
echo "[...] Checking that enough memory is available, if not a swap file will be created."

memtotal=$(grep ^MemTotal /proc/meminfo | awk '{print int($2/1024) }')

if [ $memtotal -lt 2048 -a $(swapon -s | wc -l) -lt 2 ]; then
    if [[ $EUID -ne 0 ]]; then
        echo "You don't have enough memory and the script doesn't have the permissions to allocate swap. Please run this script again as root."
        exit 1
    fi
    fallocate -l 2048M /swap || dd if=/dev/zero of=/swap bs=1M count=2048
    mkswap /swap
    grep -q "^/swap" /etc/fstab || echo "/swap swap swap defaults 0 0" >> /etc/fstab
    swapon -a
fi

echo "Creating docker volume for data"
if [ $(docker volume ls -f name=safecoin | wc -l) -ge 2 ]; then
    echo "[!!!] You already have a SafeNode container. If you want to create a new one read https://github.com/Fair-Exchange/safecoin-docker/#I-want-to-run-multiple-SafeCoin-daemons-on-my-Docker"
    exit 1
fi

docker volume create --name=safecoin-data
docker run --restart always -v safecoin-data:/safecoin --name=safecoin -d safecoin/safecoin

echo "=== Container is running ==="
echo "Follow these steps to end configuration: https://github.com/Fair-Exchange/safecoin-docker/#Configure-the-container"