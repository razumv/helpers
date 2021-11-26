#!/bin/bash
sudo systemctl stop evmos
evmosd unsafe-reset-all
wget -qO $HOME/.evmosd/config/genesis.json https://github.com/tharsis/testnets/blob/2267211602bb6e004a10a7b6e0395eed7a74b689/olympus_mons/genesis.json &>/dev/null
curl https://raw.githubusercontent.com/tharsis/testnets/main/olympus_mons/peers.txt > peers.txt
PEERS=`awk '{print $1}' peers.txt | paste -s -d, -`
sed -i.bak -e "s/^persistent_peers *=.*/persistent_peers = \"$PEERS\"/" ~/.evmosd/config/config.toml
sudo systemctl restart evmos
