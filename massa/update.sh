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
git stash
git checkout testnet
git pull

cd $HOME/massa/massa-node/
RUST_BACKTRACE=full cargo run --release compile |& tee logs.txt/ &
while [ ! -d $HOME/massa/massa-node/ledger/ ]
do
  sleep 10
done

cp $HOME/bk/node_privkey.key $HOME/massa/massa-node/config/
cp $HOME/bk/wallet.dat $HOME/massa/massa-client/

sed -i "/\[network\]/a routable_ip=\"$(wget -qO- eth0.me)\"" "$HOME/massa/massa-node/config/config.toml"

sudo systemctl start massa
