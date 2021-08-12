#!/bin/bash
sudo apt update
sudo apt install curl make clang pkg-config libssl-dev build-essential git mc jq unzip -y
curl https://getsubstrate.io -sSf | bash -s -- --fast
source $HOME/.cargo/env
sleep 1
rustup toolchain install nightly
rustup default nightly
cd $HOME
if [ ! -d $HOME/massa/ ]; then
	git clone --branch testnet https://gitlab.com/massalabs/massa.git
fi
cd $HOME/massa/massa-node/
RUST_BACKTRACE=full cargo run --release compile |& tee logs.txt/ &
while [ ! -d $HOME/massa/massa-node/ledger/ ]
do
  sleep 10
done
kill -9 $(pgrep "massa-node")
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
sudo systemctl enable massad
sudo systemctl daemon-reload
sudo systemctl restart massad

cd $HOME/massa/massa-client/
cargo run --release our_ip
while [ ! -f $HOME/massa/massa-client/config/history.txt ]
do
  sleep 10
done
rm $HOME/massa/massa-client/config/history.txt
cargo run -- --wallet wallet.dat wallet_new_privkey
while [ ! -f $HOME/massa/massa-client/config/history.txt ]
do
  sleep 10
done
cd

echo "alias client='cd $HOME/massa/massa-client/ && cargo run --release && cd'" >> ~/.profile
echo "alias clientw='cd $HOME/massa/massa-client/; cargo run -- --wallet wallet.dat; cd'" >> ~/.profile
