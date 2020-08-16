#!/bin/bash

set -e

echo "=== SafeNode Container boostrap script ==="
echo
echo -n "- "; docker -v 2> /dev/null || (echo "[ERR] Docker is needed. Please follow https://docs.docker.com/get-docker/ to install it" && false)
echo

ramtotal=$(grep ^MemTotal /proc/meminfo | awk '{print int($2/1024) }')
swaptotal=$(swapon -s | sed '1d' | awk '{ print int($3/1024) }')
memtotal=$(expr $ramtotal + $swaptotal)
if [ $memtotal -lt 2530 ]; then
    echo "You don't have enough memory to run a SafeCoin daemon. You need at least 3GB of memory."
    exit 1
fi

read -p "Do you want to run a SafeNode [y/N]: " safenode
if [[ "$safenode" == [Yy] ]]; then
    EXTRAFILES="-f docker-compose.safenode.yml"
    default_prefix="safenode"
else
    default_prefix="safecoin"
fi

read -p "Containers prefix [$default_prefix]: " container_prefix
if [ -s $container_prefix ]; then
    container_prefix="$default_prefix"
fi

read -p "Do you want to create a Tor node [Y/n]: " tor
if [[ "$tor" =~ ^(Y|y)*$ ]]; then
    EXTRAFILES="$EXTRAFILES -f docker-compose.tor.yml"
fi

read -p "Do you live in a location where Tor is censored? [y/N]: " censorship

if [[ "$censorship" == [Yy] ]]; then
    read -p "Follow these instructions: https://github.com/Fair-Exchange/safecoin-docker/tree/master/tor#use-a-obfs4-bridge-to-circumvent-censorship then press enter."
else
    read -p "Do you want to help fighting censorship (you will need to make ports 8772/8773 reachables from the internet) [Y/n]: " anticensorship
    if [[ "$anticensorship" =~ ^(Y|y)*$ ]]; then
        read -p "Email address to allow Tor team to contact you if there are problems with your bridge (optional): " EMAIL
        EXTRAFILES="$EXTRAFILES -f docker-compose.fightcens.yml"
    fi
fi
echo

docker-compose -p $container_prefix -f docker-compose.yml $EXTRAFILES build --pull
docker-compose -p $container_prefix -f docker-compose.yml $EXTRAFILES up -d


if [[ "$safenode" == [Yy] ]]; then
    echo
    echo "=== SafeNode Setup ==="
    if [ $(docker-compose -p $container_prefix exec safecoin \[ -s /safecoin/.safecoin/safecoin.conf \]) -eq 0 ]; then
        echo "Your SafeNode seems to be already configured."
        echo "To reconfigure it, runs: docker-compose -p $container_prefix exec setup-safenode.sh"
    fi
    docker-compose -p $container_prefix exec setup-safenode.sh
    docker-compose -p $container_prefix restart safecoin
fi

echo
echo "=== Container configuration ===="
echo "CONTAINER PREFIX: $container_prefix"
if [[ "$tor" =~ ^(Y|y)*$ ]]; then
    echo -n "TOR NODE ADDRESS: "
    while [ -z "$tor_address" ]; do
        tor_address=$(docker-compose -p $container_prefix exec tor cat /var/lib/tor/safecoin-node/hostname 2> /dev/null || echo)
        sleep 1
    done
    echo $tor_address
fi

echo -n "SAFECOIN ADDRESS: "
while [ ${#safecoin_address} -ne 34 ]; do
    safecoin_address=$(docker-compose -p $container_prefix exec safecoin safecoin-cli listreceivedbyaddress 0 true | grep address | cut -c17-50)
    sleep 1
done
echo $safecoin_address

if [[ "$anticensorship" =~ ^(Y|y)*$ ]]; then
    echo
    echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
    echo "!!! REMEMBER TO OPEN TCP PORTS 8772/8773 TO HELP !!!"
    echo "!!!  CENSORED USERS CONNECT TO THE TOR NETWORK   !!!"
    echo "!!!     THROUGH YOUR OBFS4 BRIDGE TO BYPASS      !!!"
    echo "!!!        CENSORSHIP AND SURVEILLANCE!          !!!"
    echo "!!!! TEST: https://bridges.torproject.org/scan/ !!!!"
    echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
    echo
fi

echo
echo "Useful commmands:"
echo "- Stop the containers: docker-compose -p $container_prefix -f docker-compose.yml $EXTRAFILES stop"
echo "- Start the containers: docker-compose -p $container_prefix -f docker-compose.yml $EXTRAFILES start"
echh "- Delete the containers (add -v to delete data too): docker-compose -p $container_prefix -f docker-compose.yml $EXTRAFILES down"
echo "- Backup your container's wallet: docker cp $(echo $container_prefix)_safecoin_1:/safecoin/.safecoin/wallet.dat ."
echo "- Update SafeCoin: run this script again."

echo
echo "=== Containers are running ==="