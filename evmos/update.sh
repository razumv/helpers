#!/bin/bash
echo "-----------------------------------------------------------------------------"
curl -s https://raw.githubusercontent.com/razumv/helpers/main/doubletop.sh | bash
echo "-----------------------------------------------------------------------------"
sudo systemctl stop evmos
rm -f $HOME/.evmosd/config/genesis.json
cd $HOME/evmos
git fetch --all && git checkout v0.2.0
make install

curl -s https://raw.githubusercontent.com/razumv/helpers/main/evmos/update_peers.sh | bash
