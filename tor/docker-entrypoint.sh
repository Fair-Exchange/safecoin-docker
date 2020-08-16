#!/bin/sh

set -e

if [ ! -d /var/lib/tor/safecoin-node ]; then
    echo "Generating address..."
    mkdir -p /var/lib/tor/safecoin-node
    while [ ! -s /var/lib/tor/safecoin-node/private_key ]; do
        eschalot -p safe | sed '1,2d' > /var/lib/tor/safecoin-node/private_key
    done
    chmod -R 700 /var/lib/tor/safecoin-node/
fi

exec tor $@