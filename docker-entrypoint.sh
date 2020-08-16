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

if [ "$1" = "-tornode" ]; then
    shift
    EXTRA_ARGS="-externalip=$(cat /var/lib/tor/safecoin-node/hostname)"
fi

echo "****************************************************"
echo "Running: safecoind $@ $EXTRA_ARGS"
echo "****************************************************"

exec safecoind $@ $EXTRA_ARGS