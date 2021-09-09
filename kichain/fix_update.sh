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

cd $HOME
mkdir $HOME/bk
cp $HOME/testnet/kid/config/node_key.json $HOME/bk/kid/config/
cp $HOME/testnet/kid/config/priv_validator_key.json $HOME/bk/kid/config/

rm -rf $HOME/testnet
#tar xvf kichain.tar.gz
#mv $HOME/root/* $HOME/testnet.old/
mkdir -p $HOME/testnet/kid $HOME/testnet/kicli

#kid init $KICHAIN_NODENAME --chain-id kichain-t-3 --home $HOME/testnet/kid/
cp $HOME/bk/kid/config/node_key.json $HOME/testnet/kid/config/
cp $HOME/bk/kid/config/priv_validator_key.json $HOME/testnet/kid/config/
wget -qO $HOME/testnet/kid/config/genesis.json https://raw.githubusercontent.com/KiFoundation/ki-networks/v0.1/Testnet/kichain-t-4/genesis.json

peers="46b25d81510f8dcc535ca0924961b266e4f59244@135.125.183.94:26656,ada3bbf64f963e764bfe003276354bd121e80ae0@95.111.248.200:26656,276f6fb420b3595b63c2a13d35868cb530a31578@65.21.159.19:26656,7e5710ee0b1576a78a21a89e1588b6c95ee69873@194.163.137.193:26656,d379efa1423ff1dbc4c0b7440d184e9916c7c110@65.21.245.204:26656,c13e9a9c530b0cee20432f329aa3ad8db2f14a24@65.108.53.143:26656,a0ea0204d3d90fad692fec066e6f3a70036d05c6@65.21.244.228:26656,7b5e05a03d0190feea821eab565a236d58d60868@45.32.239.242:26656,8c65a52337f390361bf653338c1d69bf72dbd9e7@65.21.231.114:26656,e8b9edf0e1938d75912813c6dc0d9aaa1014f051@65.21.139.170:26656,d426334a41e9b9b87bdc001b201fc8930bbb3b7d@80.92.204.18:26656,454d1bfb5db8082dadf5dcf81c200f0d37c1ac72@51.195.101.107:26656,1515ae1aa715905145ae1c5a0346f552ca0cea7d@172.105.190.70:26656,61d3d19da658c304d899db8e736e67ae1c0e9b2b@51.77.34.110:26656,130e9a709647f9efa2c780be174d69ad1f7949f1@65.21.247.250:26656"
seeds="815d447b182bbfcf729ac016bc8bb44aa8e14520@94.23.3.107:27756"
sed -i.bak -e "s/^seeds *=.*/seeds = \"$seeds\"/; s/^persistent_peers *=.*/persistent_peers = \"$peers\"/" $HOME/testnet/kid/config/config.toml
sed -i -e 's/^\(timeout_commit *=\).*/\1 "5s"/' $HOME/testnet/kid/config/config.toml

sudo systemctl restart kichain; sleep 30

kid status
