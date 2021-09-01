#!/bin/bash
sudo systemctl stop massa

mkdir -p $HOME/bk
cp $HOME/massa/massa-node/config/node_privkey.key $HOME/bk/
cp $HOME/massa/massa-client/wallet.dat $HOME/bk/

cd $HOME/massa
git stash
git checkout testnet
git pull

cp $HOME/bk/node_privkey.key $HOME/massa/massa-node/config/
cp $HOME/bk/wallet.dat $HOME/massa/massa-client/

sed -i "/\[network\]/a routable_ip=\"$(wget -qO- eth0.me)\"" "$HOME/massa/massa-node/config/config.toml"

sudo systemctl start massa
