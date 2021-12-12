#!/bin/bash

sudo systemctl stop evmos
evmosd unsafe-reset-all

cd $HOME
rm -rf evmos

git clone https://github.com/tharsis/evmos.git
cd evmos
git checkout v0.4.2
make install

sed -i.bak -e  "s/^halt-height *=.*/halt-height = 0/" $HOME/.evmosd/config/app.toml

#cosmovisor

cp $HOME/go/bin/evmosd $HOME/.evmosd/cosmovisor/genesis/bin
mkdir -p $HOME/.evmosd/cosmovisor/upgrades/Olympus-Mons-v0.4.1/bin/
cp $HOME/go/bin/evmosd $HOME/.evmosd/cosmovisor/upgrades/Olympus-Mons-v0.4.1/bin/

peers="867f01d95299fff780c5a5139c2032bc6d773806@167.86.86.48:26656"

sed -i.bak -e  "s/^persistent_peers *=.*/persistent_peers = \"$peers\"/" ~/.evmosd/config/config.toml

SNAP_RPC="http://167.86.86.48:26657" # kekeminator

LATEST_HEIGHT=$(curl -s $SNAP_RPC/block | jq -r .result.block.header.height); \
BLOCK_HEIGHT=$((LATEST_HEIGHT - 1000)); \
TRUST_HASH=$(curl -s "$SNAP_RPC/block?height=$BLOCK_HEIGHT" | jq -r .result.block_id.hash)

sed -i.bak -E "s|^(enable[[:space:]]+=[[:space:]]+).*$|\1true| ; \
s|^(rpc_servers[[:space:]]+=[[:space:]]+).*$|\1\"$SNAP_RPC,$SNAP_RPC\"| ; \
s|^(trust_height[[:space:]]+=[[:space:]]+).*$|\1$BLOCK_HEIGHT| ; \
s|^(trust_hash[[:space:]]+=[[:space:]]+).*$|\1\"$TRUST_HASH\"| ; \
s|^(seeds[[:space:]]+=[[:space:]]+).*$|\1\"\"|" ~/.evmosd/config/config.toml

sudo systemctl restart evmos
