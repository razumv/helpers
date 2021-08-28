#!/bin/bash

sudo systemctl stop kichain

curl -s https://raw.githubusercontent.com/razumv/helpers/main/tools/install_go.sh | bash

rm -rf $HOME/ki-tools
git clone https://github.com/KiFoundation/ki-tools.git
cd $HOME/ki-tools
git checkout testnet-ibc
make install

mv $HOME/testnet $HOME/testnet.old
mkdir -p $HOME/testnet/kid $HOME/testnet/kicli

kid init $KICHAIN_NODENAME --chain-id kichain-t-3 --home $HOME/testnet/kid/
cp $HOME/testnet.old/kid/config/node_key.json $HOME/testnet/kid/config/
cp $HOME/testnet.old/kid/config/priv_validator_key.json $HOME/testnet/kid/config/
wget -qO $HOME/testnet/kid/config/genesis.json https://github.com/KiFoundation/ki-networks/raw/v0.1/Testnet/kichain-t-3/genesis.json

sudo systemctl start kichain; sleep 30

kicli status
