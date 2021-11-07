#!/bin/bash

#add ufw rules
curl -s https://raw.githubusercontent.com/razumv/helpers/main/tools/install_ufw.sh | bash

sudo apt update
#sudo apt install curl make clang pkg-config libssl-dev build-essential git mc jq unzip -y
#curl https://getsubstrate.io -sSf | bash -s -- --fast
curl -s https://raw.githubusercontent.com/razumv/helpers/main/tools/install_rust.sh | bash

source $HOME/.cargo/env
sleep 1
rustup toolchain install nightly
rustup default nightly
cd $HOME
if [ ! -d $HOME/massa/ ]; then
	git clone --branch testnet https://gitlab.com/massalabs/massa.git
fi
cd $HOME/massa/massa-node/
cargo build --release
sed -i 's%bootstrap_list *=.*%bootstrap_list = [ [ "62.171.166.224:31245", "8Cf1sQA9VYyUMcDpDRi2TBHQCuMEB7HgMHHdFcsa13m4g6Ee2h",], [ "149.202.86.103:31245", "5GcSNukkKePWpNSjx9STyoEZniJAN4U4EUzdsQyqhuP3WYf6nj",], [ "149.202.89.125:31245", "5wDwi2GYPniGLzpDfKjXJrmHV3p1rLRmm4bQ9TUWNVkpYmd4Zm",], [ "158.69.120.215:31245", "5QbsTjSoKzYc8uBbwPCap392CoMQfZ2jviyq492LZPpijctb9c",], [ "158.69.23.120:31245", "8139kbee951YJdwK99odM7e6V3eW7XShCfX5E2ovG3b9qxqqrq",],]%' "$HOME/massa/massa-node/base_config/config.toml"
sed -i 's/.*routable_ip/# \0/' "$HOME/massa/massa-node/config/config.toml"
sed -i "/\[network\]/a routable_ip=\"$(curl -s ifconfig.me)\"" "$HOME/massa/massa-node/config/config.toml"

sudo tee <<EOF >/dev/null /etc/systemd/system/massa.service
[Unit]
Description=Massa Node
After=network-online.target
[Service]
User=$USER
Restart=always
RestartSec=3
LimitNOFILE=65535
WorkingDirectory=$HOME/massa/massa-node
ExecStart=$HOME/massa/target/release/massa-node
[Install]
WantedBy=multi-user.target
EOF

sudo tee <<EOF >/dev/null /etc/systemd/journald.conf
Storage=persistent
EOF

sudo systemctl restart systemd-journald
sudo systemctl enable massa
sudo systemctl daemon-reload
sudo systemctl restart massa

cd $HOME/massa/massa-client/
# cargo run --release
# while [ ! -f $HOME/massa/massa-client/config/history.txt ]
# do
#   sleep 10
# done
# rm $HOME/massa/massa-client/config/history.txt
cargo run -- --wallet wallet.dat wallet_generate_private_key
# while [ ! -f $HOME/massa/massa-client/config/history.txt ]
# do
#   sleep 10
# done
# cd

echo "alias client='cd $HOME/massa/massa-client/ && cargo run --release && cd'" >> ~/.profile
echo "alias clientw='cd $HOME/massa/massa-client/; cargo run -- --wallet wallet.dat; cd'" >> ~/.profile

mkdir -p $HOME/bk
cp $HOME/massa/massa-node/config/node_privkey.key $HOME/bk/
cp $HOME/massa/massa-client/wallet.dat $HOME/bk/
if [ ! -e $HOME/massa_bk.tar.gz ]; then
	tar cvzf massa_bk.tar.gz bk
fi
