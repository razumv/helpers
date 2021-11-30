#!/bin/bash
if [ ! -e $HOME/account_aleo.txt ]; then
  cp $HOME/aleo/account.txt $HOME/account_aleo.txt
fi
#add ufw rules
curl -s https://raw.githubusercontent.com/razumv/helpers/main/tools/install_ufw.sh | bash

sudo apt install wget -y
rustup update
sudo systemctl stop miner
rm -rf $HOME/snarkOS
git clone https://github.com/AleoHQ/snarkOS.git --depth 1
cd $HOME/snarkOS
cargo build --release --verbose

sudo tee <<EOF >/dev/null /etc/systemd/journald.conf
Storage=persistent
EOF
sudo systemctl restart systemd-journald

echo 'export MINER_ADDRESS='$(cat $HOME/account_aleo.txt | awk '/Address/ {print $2}') >> $HOME/.profile
source $HOME/.profile
sed -i "s/MINER_ADDRESS=\".*\"/MINER_ADDRESS=\"${MINER_ADDRESS}\"/g" $HOME/snarkOS/run-miner.sh

sudo tee <<EOF >/dev/null /etc/systemd/system/miner.service
[Unit]
Description=Aleo miner
After=network-online.target
[Service]
Environment=PATH="/root/.cargo/bin/:$PATH"
Environment=MINER_ADDRESS=$(cat $HOME/account_aleo.txt | awk '/Address/ {print $2}')
User=$USER
WorkingDirectory=$HOME/snarkOS
ExecStart=$HOME/snarkOS/run-miner.sh
Restart=always
RestartSec=10
LimitNOFILE=10000
[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable miner
sudo systemctl restart miner
