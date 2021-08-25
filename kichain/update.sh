#!/bin/bash

sudo systemctl stop kichain

cd $HOME/testnet
cp -r ./kid ./kid-backup
kid export --height=64800 --home ./kid > kichain-t-2_genesis_export.json

cd $HOME/ki-tools
git fetch
git checkout testnet-ibc
make install

cd $HOME/testnet
kid migrate kichain-t-2_genesis_export.json --chain-id=kichain-t-3 --initial-height 64801 > genesis.json

mv ./kid/config/config.toml ./kid/config/config.toml.kichain-t-2.bak
mv ./kid/config/app.toml ./kid/config/app.toml.kichain-t-2.bak

kid unsafe-reset-all --home ./kid

cp genesis.json ./kid/config/

sed -i -e "s/^moniker *=.*/moniker = \"$KICHAIN_NODENAME\"/" $HOME/testnet/kid/config/config.toml

sudo systemctl start kichain
