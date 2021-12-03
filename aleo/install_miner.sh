#!/bin/bash

#add ufw rules
curl -s https://raw.githubusercontent.com/razumv/helpers/main/tools/install_ufw.sh | bash

sudo apt update
sudo apt install curl make clang pkg-config libssl-dev build-essential git mc jq unzip -y
sudo curl https://sh.rustup.rs -sSf | sh -s -- -y
source $HOME/.cargo/env
sleep 1

git clone https://github.com/AleoHQ/snarkOS.git --depth 1
cd snarkOS
cargo build --release --verbose
$HOME/snarkOS/target/release/snarkos experimental new_account >> $HOME/account_aleo.txt
sleep 2
echo 'export MINER_ADDRESS='$(cat $HOME/account_aleo.txt | awk '/Address/ {print $2}') >> $HOME/.profile
source $HOME/.profile
sleep 1
echo -e '\n\e[42mYour address - \e[0m' && echo ${MINER_ADDRESS} && sleep 1

sudo tee <<EOF >/dev/null /etc/systemd/journald.conf
Storage=persistent
EOF
sudo systemctl restart systemd-journald

sudo tee <<EOF >/dev/null /etc/systemd/system/miner.service
[Unit]
Description=Aleo Node
After=network-online.target
[Service]
User=$USER
ExecStart=$HOME/snarkOS/target/release/snarkos --trial --miner $MINER_ADDRESS
Restart=always
RestartSec=10
LimitNOFILE=10000
[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable miner
sudo systemctl restart miner

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

sudo tee <<EOF >/dev/null $HOME/miner_update.sh
cd $HOME/snarkOS
while :
do
  echo "Checking for updates..."
  STATUS=$(git pull)

  echo $STATUS

  if [ "$STATUS" != "Already up to date." ]; then
	source $HOME/.cargo/env
	cargo clean
	cargo build --release
	# cargo clean
	if [[ `service miner status | grep active` =~ "running" ]]; then
	  echo "Aleo Miner is active"
	  systemctl stop miner
	  ALEO_IS_MINER=true
	fi
	if [[ `echo $ALEO_IS_MINER` =~ "true" ]]; then
	  echo "Aleo Miner restarted"
	  systemctl restart miner
	fi
  fi
done
EOF
#thanks nodes.guru for this script :)

chmod +x $HOME/miner_update.sh

sudo tee <<EOF >/dev/null /etc/cron.d/
*/30 * * * * $HOME/miner_update.sh
EOF
