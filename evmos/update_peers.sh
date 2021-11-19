#!/bin/bash
sudo systemctl stop evmos
evmosd unsafe-reset-all
wget -qO $HOME/.evmosd/config/genesis.json https://github.com/tharsis/testnets/blob/2267211602bb6e004a10a7b6e0395eed7a74b689/olympus_mons/genesis.json &>/dev/null
bootstrap_node="http://5.189.156.65:26657"; \
latest_height=`wget -qO- "${bootstrap_node}/block" | jq -r ".result.block.header.height"`; \
block_height=$((latest_height - 2000)); \
trust_hash=`wget -qO- "${bootstrap_node}/block?height=${block_height}" | jq -r ".result.block_id.hash"`; \
sed -i -e "s%^moniker *=.*%moniker = \"$EVMOS_NODENAME\"%; "\
"s%^seeds *=.*%seeds = \"`wget -qO - https://raw.githubusercontent.com/tharsis/testnets/2267211602bb6e004a10a7b6e0395eed7a74b689/olympus_mons/seeds.txt | tr '\n' ',' | sed 's%,$%%'`\"%; "\
"s%^persistent_peers *=.*%persistent_peers = \"`wget -qO - https://raw.githubusercontent.com/razumv/helpers/main/evmos/peers.txt | tr '\n' ',' | sed 's%,$%%'`,`wget -qO - https://raw.githubusercontent.com/tharsis/testnets/2267211602bb6e004a10a7b6e0395eed7a74b689/olympus_mons/peers.txt | tr '\n' ',' | sed 's%,$%%'`\"%; "\
"s%^enable *=.*%enable = false%; "\
"s%^rpc_servers *=.*%rpc_servers = \"${bootstrap_node},${bootstrap_node}\"%; "\
"s%^trust_height *=.*%trust_height = $block_height%; "\
"s%^trust_hash *=.*%trust_hash = \"$trust_hash\"%" $HOME/.evmosd/config/config.toml
sudo systemctl restart evmos
