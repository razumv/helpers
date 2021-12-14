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

cp $HOME/go/bin/evmosd $HOME/.evmosd/cosmovisor/genesis/bin
mkdir -p $HOME/.evmosd/cosmovisor/upgrades/Olympus-Mons-v0.4.1/bin/
cp $HOME/go/bin/evmosd $HOME/.evmosd/cosmovisor/upgrades/Olympus-Mons-v0.4.1/bin/

peers="99899432a8cdf5b5ff0a9bc6b07dfa240ea3ea33@213.21.221.202:26656,184866519dfa093076ff7a31eddb5bf7b8e1809f@213.21.221.203:26656,a9a1b9845afe75d314b8b5fa762bfed012b3af34@65.21.227.224:26656,cccdaee68c9f051bd227371424b4d5db6558cbff@144.91.79.203:26656,29558c38f6894066ebafa9f156f2839db9d454f6@23.88.0.168:26656,c893e2bf76b60099eecc20d4a9671ed9d4114464@65.21.193.112:26656"

sed -i.bak -e  "s/^persistent_peers *=.*/persistent_peers = \"$peers\"/" ~/.evmosd/config/config.toml

SNAP_RPC="https://evmos-rpc.mercury-nodes.net:443"

LATEST_HEIGHT=$(curl -s $SNAP_RPC/block | jq -r .result.block.header.height); \
BLOCK_HEIGHT=$((LATEST_HEIGHT - 1000)); \
TRUST_HASH=$(curl -s "$SNAP_RPC/block?height=$BLOCK_HEIGHT" | jq -r .result.block_id.hash)

sed -i.bak -E "s|^(enable[[:space:]]+=[[:space:]]+).*$|\1true| ; \
s|^(rpc_servers[[:space:]]+=[[:space:]]+).*$|\1\"$SNAP_RPC,$SNAP_RPC\"| ; \
s|^(trust_height[[:space:]]+=[[:space:]]+).*$|\1$BLOCK_HEIGHT| ; \
s|^(trust_hash[[:space:]]+=[[:space:]]+).*$|\1\"$TRUST_HASH\"| ; \
s|^(seeds[[:space:]]+=[[:space:]]+).*$|\1\"\"|" ~/.evmosd/config/config.toml

sed -i.bak -e  "s/^discovery_time *=.*/discovery_time = \"30s\"/" ~/.evmosd/config/config.toml

curl -s http://65.21.193.112/addrbook.json > $HOME/.evmosd/config/addrbook.json

sudo systemctl restart evmos
