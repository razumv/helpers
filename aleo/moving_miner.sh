#!/bin/bash
export ALEO_ADDRESS=$(cat $HOME/aleo/account.txt | awk '/Address/ {print $2}')

sudo tee <<EOF >/dev/null /etc/systemd/system/miner.service
[Unit]
Description=Aleo Node
After=network-online.target
[Service]
User=$USER
ExecStart=$HOME/snarkOS/target/release/snarkos --is-miner --miner-address '$ALEO_ADDRESS'
Restart=always
RestartSec=10
LimitNOFILE=10000
[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload

sudo systemctl restart miner
