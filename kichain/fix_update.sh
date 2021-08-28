#!/bin/bash

sudo systemctl stop kichain

curl -s https://raw.githubusercontent.com/razumv/helpers/main/tools/install_go.sh | bash
source $HOME/.profile
sleep 1

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

peers="d426334a41e9b9b87bdc001b201fc8930bbb3b7d@80.92.204.18:26656,8c65a52337f390361bf653338c1d69bf72dbd9e7@134.209.91.200:26656,454d1bfb5db8082dadf5dcf81c200f0d37c1ac72@51.195.101.107:26656,1515ae1aa715905145ae1c5a0346f552ca0cea7d@172.105.190.70:26656,61d3d19da658c304d899db8e736e67ae1c0e9b2b@51.77.34.110:26656,130e9a709647f9efa2c780be174d69ad1f7949f1@65.21.247.250:26656,bf8077c39cd50aa5f71d90b4397504db8ef2f78f@65.21.155.101:26656,658c9d46a00d86ae5805054fddad53caa5ef26f1@86.107.197.35:26656,fbcffeaa6e53e979d14d87893b2b36f06b7fb9ae@194.163.163.146:26656,4226ce46bcef2101a7c4e6d945dfd27a423e3440@78.46.250.232:26656,9e58976e1fba62cf0c4e7ca00bae98e207d2d0e2@5.9.117.93:26899,dd2d68c16620017e003cf5ca24193cfeb8c26e36@198.244.164.111:26656,454d1bfb5db8082dadf5dcf81c200f0d37c1ac72@51.195.101.107:26656"
seeds="815d447b182bbfcf729ac016bc8bb44aa8e14520@94.23.3.107:27756"
sed -i.bak -e "s/^seeds *=.*/seeds = \"$seeds\"/; s/^persistent_peers *=.*/persistent_peers = \"$peers\"/" $HOME/testnet/kid/config/config.toml
sed -i -e 's/^\(timeout_commit *=\).*/\1 "5s"/' $HOME/testnet/kid/config/config.toml

sudo systemctl start kichain; sleep 30

kid status
