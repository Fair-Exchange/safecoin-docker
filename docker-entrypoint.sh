#!/bin/sh

if [ ! -f $HOME/.safecoin/safecoin.conf ]; then
    mkdir $HOME/safecoin/
    touch $HOME/.safecoin/safecoin.conf
fi

echo "Checking fetch-params..."
fetch-params.sh > /dev/null
echo "Initialization completed successfully"
echo

echo "****************************************************"
echo "Running: safecoind $@"
echo "****************************************************"

exec safecoind $@