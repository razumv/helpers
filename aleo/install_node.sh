#!/bin/bash
sudo apt update
sudo apt install make clang pkg-config libssl-dev build-essential git mc jq unzip -y
curl https://getsubstrate.io -sSf | bash -s -- --fast 
source $HOME/.cargo/env
sleep 1

git clone https://github.com/AleoHQ/snarkOS
cd snarkOS
git checkout v1.3.13
#cargo build --release --verbose
wget https://github.com/AleoHQ/snarkOS/releases/download/v1.3.13/aleo-testnet1-v1.3.13-x86_64-unknown-linux-gnu.zip
unzip aleo-testnet1-v1.3.13-x86_64-unknown-linux-gnu.zip
mkdir -p $HOME/snarkOS/target/release/
mv snarkos $HOME/snarkOS/target/release/
rm -f aleo-testnet1-v1.3.13-x86_64-unknown-linux-gnu.zip

sudo tee <<EOF >/dev/null /etc/systemd/system/aleo.service
[Unit]
Description=Aleo Node
After=network-online.target
[Service]
User=$USER
ExecStart=$HOME/snarkOS/target/release/snarkos
Restart=always
RestartSec=10
LimitNOFILE=10000
[Install]
WantedBy=multi-user.target
EOF

sudo tee <<EOF >/dev/null /etc/systemd/journald.conf
Storage=persistent
EOF

cd $HOME
mkdir -p $HOME/.snarkOS
#update snapshot
block=380000
wget 188.166.34.137/backup_snarkOS_$block.tar.gz
tar xvf backup_snarkOS_$block.tar.gz
mv backup_snarkOS_$block/.snarkOS/* $HOME/.snarkOS/
rm -rf backup_snarkOS_$block*

sudo systemctl restart systemd-journald
sudo systemctl daemon-reload
sudo systemctl enable aleo
sudo systemctl restart aleo

echo -e '\n\e[44mRun command to see logs: \e[0m\n'
echo "journalctl -n 100 -f -u aleo -o cat | grep -v 'p[io]ng'| grep -v Couldn\'t | grep -v 'Received a' | grep -v 'Sent a' | grep -C1 canon"

tee <<EOF >/dev/null $HOME/monitoring.sh
echo "PEERS:";
curl -s --data-binary '{"jsonrpc": "2.0", "id":"documentation", "method": "getpeerinfo", "params": [] }' -H 'content-type: application/json' http://localhost:3030/   | jq '.[].peers?';
echo "NODE INFO:";
curl -s --data-binary '{"jsonrpc": "2.0", "id":"documentation", "method": "getnodeinfo", "params": [] }' -H 'content-type: application/json' http://localhost:3030/ | jq '.result?';
printf "CONNECTION COUNT:\t";
curl -s --data-binary '{"jsonrpc": "2.0", "id":"documentation", "method": "getconnectioncount", "params": [] }' -H 'content-type: application/json' http://localhost:3030/ | jq '.result?';
printf "BLOCK COUNT:\t\t";
curl -s --data-binary '{"jsonrpc": "2.0", "id":"documentation", "method": "getblockcount", "params": [] }' -H 'content-type: application/json' http://localhost:3030/ | jq '.result?';
echo "OVERALL:";
curl -s --data-binary '{"jsonrpc": "2.0", "id":"1", "method": "getnodestats" }' -H 'content-type:application/json' http://localhost:3030/ | jq '.result?';
echo ""
EOF

chmod +x $HOME/monitoring.sh