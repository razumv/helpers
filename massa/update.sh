#!/bin/bash
sudo systemctl stop massa

cd $HOME
mkdir -p $HOME/bk
cp $HOME/massa/massa-node/config/node_privkey.key $HOME/bk/
cp $HOME/massa/massa-client/wallet.dat $HOME/bk/
if [ ! -e $HOME/massa_bk.tar.gz ]; then
	tar cvzf massa_bk.tar.gz bk
fi

cd $HOME/massa
git checkout -- massa-node/config/config.toml
git checkout -- massa-node/config/peers.json
git stash
git checkout testnet
git pull

cd $HOME/massa/massa-node/
cargo build --release
sed -i "/\[network\]/a routable_ip=\"$(curl -s ifconfig.me)\"" "$HOME/massa/massa-node/config/config.toml"
cp $HOME/bk/node_privkey.key $HOME/massa/massa-node/config/node_privkey.key

cd $HOME/massa/massa-client/
cargo build --release
cp $HOME/bk/wallet.dat $HOME/massa/massa-client/wallet.dat

sudo systemctl start massa
sleep 10
echo DONE
#massa_wallet_address=$(cargo run --release wallet_info | grep Address  |awk '{print $2}')
#cargo run --release -- buy_rolls $massa_wallet_address 1 0
#cargo run --release -- register_staking_keys $(cargo run --release wallet_info | grep Private | awk '{print $3}')
