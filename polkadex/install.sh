#!/bin/bash

if [ ! $NODENAME ]; then
	read -p "Введите ваше имя ноды(придумайте): " NODENAME
fi
sleep 1
echo 'export NODENAME='$NODENAME >> $HOME/.profile

sudo apt install git mc jq htop net-tools -y

curl -s https://raw.githubusercontent.com/razumv/helpers/main/tools/install_rust.sh | bash
source $HOME/.cargo/env
sleep 1

rustup toolchain add nightly-2021-05-11
rustup target add wasm32-unknown-unknown --toolchain nightly-2021-05-11
rustup target add x86_64-unknown-linux-gnu --toolchain nightly-2021-05-11

cd $HOME
curl -O -L https://github.com/Polkadex-Substrate/Polkadex/releases/download/v0.4.0/customSpecRaw.json
git clone https://github.com/Polkadex-Substrate/Polkadex.git
cd $HOME/Polkadex
git checkout v0.4.0
cargo build --release

sudo tee <<EOF >/dev/null /etc/systemd/journald.conf
Storage=persistent
EOF
sudo systemctl restart systemd-journald

sudo tee <<EOF >/dev/null /etc/systemd/system/polkadex.service
[Unit]
Description=Polkadex Testnet Validator Service
After=network-online.target
Wants=network-online.target

[Service]
User=ubuntu
Group=ubuntu
ExecStart=$HOME/Polkadex/target/release/polkadex-node --chain=$HOME/customSpecRaw.json --rpc-cors=all --bootnodes /ip4/13.235.92.50/tcp/30333/p2p/12D3KooWBRsL9KPkMeWxTMq5aSbgUWEMgwzWpWDA6EqQ6A2KTDoR --validator --name '$POLKADEX_NODENAME | DOUBLETOP'
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable polkadex
sudo systemctl restart polkadex
