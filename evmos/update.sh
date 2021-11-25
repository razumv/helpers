#!/bin/bash
echo "-----------------------------------------------------------------------------"
curl -s https://raw.githubusercontent.com/razumv/helpers/main/doubletop.sh | bash
echo "-----------------------------------------------------------------------------"
git clone https://github.com/cosmos/cosmos-sdk
cd cosmos-sdk
git checkout v0.44.3
make cosmovisor
cp cosmovisor/cosmovisor $GOPATH/bin/cosmovisor
cd $HOME

mkdir -p ~/.evmosd
mkdir -p ~/.evmosd/cosmovisor
mkdir -p ~/.evmosd/cosmovisor/genesis
mkdir -p ~/.evmosd/cosmovisor/genesis/bin
mkdir -p ~/.evmosd/cosmovisor/upgrades

echo "# Setup Cosmovisor" >> ~/.profile
echo "export DAEMON_NAME=evmosd" >> ~/.profile
echo "export DAEMON_HOME=$HOME/.evmosd" >> ~/.profile
echo 'export PATH="$DAEMON_HOME/cosmovisor/current/bin:$PATH"' >> ~/.profile
source ~/.profile

sudo systemctl stop evmos
rm -f $HOME/.evmosd/config/genesis.json
cd $HOME/evmos
git fetch --all && git checkout v0.3.0
make install

cp $GOPATH/bin/evmosd ~/.evmosd/cosmovisor/genesis/bin

evmosd config chain-id evmos_9000-2

curl https://raw.githubusercontent.com/tharsis/testnets/main/olympus_mons/genesis.json > ~/.evmosd/config/genesis.json

evmosd unsafe-reset-all

sudo tee /etc/systemd/system/evmos.service > /dev/null <<EOF
[Unit]
Description=Evmos Daemon
After=network-online.target

[Service]
User=$USER
ExecStart=$(which cosmovisor) start
Restart=always
RestartSec=3
LimitNOFILE=infinity

Environment="DAEMON_HOME=$HOME/.evmosd"
Environment="DAEMON_NAME=evmosd"
Environment="DAEMON_ALLOW_DOWNLOAD_BINARIES=false"
Environment="DAEMON_RESTART_AFTER_UPGRADE=true"

[Install]
WantedBy=multi-user.target
EOF

sudo -S systemctl daemon-reload
sudo -S systemctl enable evmos
sudo -S systemctl start evmos

echo "-----------------------------------------------------------------------------"
echo "Обновление завершено"
echo "-----------------------------------------------------------------------------"
