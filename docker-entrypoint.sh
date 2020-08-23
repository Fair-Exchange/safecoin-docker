#!/bin/sh

set -e

if [ ! -f $HOME/.safecoin/safecoin.conf ]; then
    mkdir $HOME/.safecoin/
    touch $HOME/.safecoin/safecoin.conf
fi

echo "Checking fetch-params..."
fetch-params.sh > /dev/null
echo "Initialization completed successfully"
echo

TOR_PROXY=$(getent hosts tor | awk '{ print $1 }')
if [ ! -z "$TOR_PROXY" ]; then
    if [ "$TORNODE" = 1 ]; then
        EXTRA_ARGS="-proxy=$TOR_PROXY -externalip=$(cat /var/lib/tor/safecoin-node/hostname) -listen -listenonion=0"
    else
        EXTRA_ARGS="-onion=$TOR_PROXY"
    fi
else
    echo "Tor support is disabled because not Tor proxy has been found."
    echo
fi

echo "****************************************************"
echo "Running: safecoind $EXTRA_ARGS $@"
echo "****************************************************"

exec safecoind $EXTRA_ARGS $@