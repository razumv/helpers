#!/bin/bash
source $HOME/.profile
source $HOME/.cargo/env

#add ufw rules
curl -s https://raw.githubusercontent.com/razumv/helpers/main/tools/install_ufw.sh | bash

sudo systemctl stop massa
rustup toolchain install nightly-2022-01-09
rustup default nightly-2022-01-09
#
# cd $HOME
# if [ ! -d $HOME/bk/ ]; then
# 	mkdir -p $HOME/bk
# 	cp $HOME/massa/massa-node/config/node_privkey.key $HOME/bk/
# 	cp $HOME/massa/massa-client/wallet.dat $HOME/bk/
# fi
# if [ ! -e $HOME/massa_bk.tar.gz ]; then
# 	tar cvzf massa_bk.tar.gz bk
# fi
#
# rm -rf $HOME/massa
git clone https://github.com/massalabs/massa.git
cd $HOME/massa
git checkout -- massa-node/config/config.toml
git checkout -- massa-node/config/peers.json
git fetch
git checkout TEST.10.1

cd $HOME/massa/massa-node/
cargo build --release
#sed -i 's%bootstrap_list *=.*%bootstrap_list = [ [ "62.171.166.224:31245", "8Cf1sQA9VYyUMcDpDRi2TBHQCuMEB7HgMHHdFcsa13m4g6Ee2h",], [ "149.202.86.103:31245", "5GcSNukkKePWpNSjx9STyoEZniJAN4U4EUzdsQyqhuP3WYf6nj",], [ "149.202.89.125:31245", "5wDwi2GYPniGLzpDfKjXJrmHV3p1rLRmm4bQ9TUWNVkpYmd4Zm",], [ "158.69.120.215:31245", "5QbsTjSoKzYc8uBbwPCap392CoMQfZ2jviyq492LZPpijctb9c",], [ "158.69.23.120:31245", "8139kbee951YJdwK99odM7e6V3eW7XShCfX5E2ovG3b9qxqqrq",],]%' "$HOME/massa/massa-node/base_config/config.toml"
sed -i "s/ip *=.*/ip = \"127\.0\.0\.1\"/" "$HOME/massa/massa-client/base_config/config.toml"
sed -i "s/^bind_private *=.*/bind_private = \"127\.0\.0\.1\:33034\"/" "$HOME/massa/massa-node/base_config/config.toml"
sed -i "s/^bind_public *=.*/bind_public = \"0\.0\.0\.0\:33035\"/" "$HOME/massa/massa-node/base_config/config.toml"
sed -i 's/.*routable_ip/# \0/' "$HOME/massa/massa-node/base_config/config.toml"
sed -i "/\[network\]/a routable_ip=\"$(curl -s ifconfig.me)\"" "$HOME/massa/massa-node/base_config/config.toml"

cp $HOME/bk/node_privkey.key $HOME/massa/massa-node/config/node_privkey.key

cd $HOME/massa/massa-client/
cargo build --release
cp $HOME/bk/wallet.dat $HOME/massa/massa-client/wallet.dat

curl -s https://raw.githubusercontent.com/razumv/helpers/main/massa/bootstrap-fix.sh | bash
sleep 10
echo DONE
#massa_wallet_address=$(cargo run --release wallet_info | grep Address  |awk '{print $2}')
#cargo run --release -- buy_rolls $massa_wallet_address 1 0
#cargo run --release -- register_staking_keys $(cargo run --release wallet_info | grep Private | awk '{print $3}')
