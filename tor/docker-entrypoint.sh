#!/bin/sh

set -e

cp /etc/tor/torrc.default /etc/tor/torrc
if [ "$TORNODE" = 1 ]; then
    while true; do
        safecoin_ip=$(getent hosts safecoin | awk '{ print $1 }')
        if [ ! -z "$safecoin_ip" ]; then
            break
        fi
        sleep 1
    done
    echo "
HiddenServiceDir /var/lib/tor/safecoin-node/
HiddenServicePort 8770 $safecoin_ip:8770
HiddenServiceVersion 2" >> /etc/tor/torrc
    if [ ! -d /var/lib/tor/safecoin-node ]; then
        echo "Generating address..."
        mkdir -p /var/lib/tor/safecoin-node
        while [ ! -s /var/lib/tor/safecoin-node/private_key ]; do
            eschalot -p safe | sed '1,2d' > /var/lib/tor/safecoin-node/private_key
        done
        chmod -R 700 /var/lib/tor/safecoin-node/
    fi
fi

exec tor $@