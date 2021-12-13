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

peers="694b92d4a2af1ca11428225c82b23c21e6ea4d39@95.216.10.174:26656,ef1f3310235fa2ebf4888981b976bfcaaa1b0f78@108.209.102.187:26642,e3171580ebf1c23b04a6cf2b3fa9ecb48ce8c897@5.189.178.248:26656,10aff634aa22c8b20d17769e1711c0213eae5222@65.108.84.56:26656,fab7e5bb640c153d5d485e8389a48c930afbab12@65.21.176.89:26656,9fa1770a6b8eb48b84d73119d0dbbae768ea3c08@65.108.54.98:26656,9db0e6da3ab4ea950500e2e7798d75b35ffb77bd@5.9.55.154:26656,951d890fe8b77597d3b2bb379afa76a59d63fc40@65.21.234.158:26656,bc61e4a05ed5f34313f2316d2ea00d6494b4fa69@89.163.219.63:26656,90663c8dc802ae28ccf9776e3e12b97d1a34737c@5.9.22.226:15656,6b348990e4e1e3cffae32180fd15bf6aaad9938a@161.97.185.15:26656,b4c65992274ce58f37efd825eef1a75ed1740213@185.182.9.92:26656,7085fe78b04515961dfc75726cdbd42f47155ab7@35.188.138.38:26656,0c24d5f8646de0186de4055a494a0711e991b2dc@207.180.224.205:26656,13e16244a9ddd2d2cb621be0cefdb610d3fed052@65.108.11.115:26656,223c8560c108a3666572a720504e0433c2cb3a21@207.180.203.158:26656,da55d84a69a1b67fb39d7b597834f018f2baa767@34.125.141.89:26656,bd27dad4eb51a18836f58a01385142d92032f6df@34.102.117.30:26656,4a29ed02a61ac4ec627a6572c6825a49dffc5125@95.179.253.245:26656,bd743af69a10386f4a588eff623665306fd65e97@167.86.110.154:26656,03ee8a25dd9965e72f045b9478662ea7e4a5ec34@161.97.149.115:26656,f5431883a40c6eac627576af7422672cd6526e3d@95.179.139.123:26656,e2f5a50a908a4c438cb2cce18c9773ce1b6b11e7@185.234.69.123:26656,6f405b4e00347549e6b2d44e02802a56e77e4f4e@194.19.235.88:26656,b225299a6461877256bb43228a70748dfe160897@144.91.102.83:26656"

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

sudo systemctl restart evmos
