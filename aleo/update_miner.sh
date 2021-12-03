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
# sed -i "s/MINER_ADDRESS=\".*\"/MINER_ADDRESS=\"${MINER_ADDRESS}\"/g" $HOME/snarkOS/run-miner.sh

# sudo tee <<EOF >/dev/null /etc/systemd/system/miner.service
# [Unit]
# Description=Aleo miner
# After=network-online.target
# [Service]
# Environment=PATH="/root/.cargo/bin/:$PATH"
# Environment=MINER_ADDRESS=$(cat $HOME/account_aleo.txt | awk '/Address/ {print $2}')
# User=$USER
# WorkingDirectory=$HOME/snarkOS
# ExecStart=$HOME/snarkOS/run-miner.sh
# Restart=always
# RestartSec=10
# LimitNOFILE=10000
# [Install]
# WantedBy=multi-user.target
# EOF
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
