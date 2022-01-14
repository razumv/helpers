#!/bin/bash
echo "-----------------------------------------------------------------------------"
curl -s https://raw.githubusercontent.com/razumv/helpers/main/doubletop.sh | bash
echo "-----------------------------------------------------------------------------"
source $HOME/.profile
if [ ! -d $HOME/celestia-node ]; then
  git clone https://github.com/celestiaorg/celestia-node.git &>/dev/null
fi
echo "Репозиторий успешно склонирован, начинаем билд"
echo "-----------------------------------------------------------------------------"
cd $HOME/celestia-node
git checkout v0.1.1 &>/dev/null
make install &>/dev/null
echo "Билд закончен, переходим к инициализации фулл ноды"
echo "-----------------------------------------------------------------------------"

TRUSTED_SERVER="localhost:26657"
TRUSTED_HASH=$(curl -s $TRUSTED_SERVER/status | jq -r .result.sync_info.latest_block_hash)
echo 'export TRUSTED_SERVER='${TRUSTED_SERVER} >> $HOME/.profile
echo 'export TRUSTED_HASH='${TRUSTED_HASH} >> $HOME/.profile
source $HOME/.profile

celestia full init --core.remote tcp://127.0.0.1:26657 --headers.trusted-hash $TRUSTED_HASH  &>/dev/null
sed -i.bak -e 's/PeerExchange = false/PeerExchange = true/g' $HOME/.celestia-full/config.toml

sudo tee /etc/systemd/system/celestia-full.service > /dev/null <<EOF
[Unit]
  Description=celestia-full node
  After=network-online.target
[Service]
  User=$USER
  ExecStart=$(which celestia) full start
  Restart=on-failure
  RestartSec=10
  LimitNOFILE=4096
[Install]
  WantedBy=multi-user.target
EOF

sudo systemctl enable celestia-full &>/dev/null
sudo systemctl daemon-reload
sudo systemctl restart celestia-full && sleep 10 && journalctl -u celestia-full -o cat -n 10000 --no-pager | grep -m 1 "*  /ip4/" > $HOME/multiaddress.txt

FULL_NODE_IP=$(cat $HOME/multiaddress.txt | sed -r 's/^.{3}//')
echo 'export FULL_NODE_IP='${FULL_NODE_IP} >> $HOME/.profile
source $HOME/.profile

echo "Инициализация фулл ноды закончена, переходим к инициализации лайт клиента"
echo "-----------------------------------------------------------------------------"

rm -rf $HOME/.celestia-light
celestia light init --headers.trusted-peer $FULL_NODE_IP --headers.trusted-hash $TRUSTED_HASH &>/dev/null
sed -i.bak -e "s|BootstrapPeers = \[\]|BootstrapPeers = \[\"$FULL_NODE_IP\"\]|g" $HOME/.celestia-light/config.toml
sed -i.bak -e "s|MutualPeers = \[\]|MutualPeers = \[\"$FULL_NODE_IP\"\]|g" $HOME/.celestia-light/config.toml
sed -i.bak -e 's/PeerExchange = false/PeerExchange = true/g' $HOME/.celestia-light/config.toml
sed -i.bak -e 's/Bootstrapper = false/Bootstrapper = true/g' $HOME/.celestia-light/config.toml

sudo tee /etc/systemd/system/celestia-light.service > /dev/null <<EOF
[Unit]
  Description=celestia-light
  After=network-online.target
[Service]
  User=$USER
  ExecStart=$(which celestia) light start
  Restart=on-failure
  RestartSec=10
  LimitNOFILE=4096
[Install]
  WantedBy=multi-user.target
EOF

sudo systemctl enable celestia-light &>/dev/null
sudo systemctl daemon-reload
sudo systemctl restart celestia-light

echo "Инициализация лайт клиента закончена, установка завершена"
echo "-----------------------------------------------------------------------------"
