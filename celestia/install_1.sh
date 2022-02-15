#!/bin/bash
echo "-----------------------------------------------------------------------------"
curl -s https://raw.githubusercontent.com/razumv/helpers/main/doubletop.sh | bash
echo "-----------------------------------------------------------------------------"
if [ ! $CELESTIA_NODENAME ]; then
	read -p "Введите ваше имя ноды(придумайте, без спецсимволов - только буквы и цифры): " CELESTIA_NODENAME
fi
sleep 1
CELESTIA_CHAIN="devnet-2"
echo 'export CELESTIA_CHAIN='$CELESTIA_CHAIN >> $HOME/.profile
echo 'export CELESTIA_NODENAME='$CELESTIA_NODENAME >> $HOME/.profile
echo "-----------------------------------------------------------------------------"
echo "Устанавливаем софт"
echo "-----------------------------------------------------------------------------"
curl -s https://raw.githubusercontent.com/razumv/helpers/main/tools/install_ufw.sh | bash &>/dev/null
curl -s https://raw.githubusercontent.com/razumv/helpers/main/tools/install_go.sh | bash &>/dev/null
sudo apt install --fix-broken -y &>/dev/null
sudo apt install nano mc wget -y &>/dev/null
source .profile
source .bashrc
sleep 1
echo "Весь необходимый софт установлен"
echo "-----------------------------------------------------------------------------"
if [ ! -d $HOME/celestia-app ]; then
  git clone https://github.com/celestiaorg/celestia-app.git &>/dev/null
fi
if [ ! -d $HOME/networks ]; then
  git clone https://github.com/celestiaorg/networks.git &>/dev/null
fi
echo "Репозиторий успешно склонирован, начинаем билд"
echo "-----------------------------------------------------------------------------"
cd $HOME/celestia-app/
make install &>/dev/null
echo "Билд закончен, переходим к инициализации ноды"
echo "-----------------------------------------------------------------------------"
celestia-appd init $CELESTIA_NODENAME --chain-id $CELESTIA_CHAIN &>/dev/null
cp $HOME/networks/devnet-2/genesis.json $HOME/.celestia-app/config/
SEEDS="74c0c793db07edd9b9ec17b076cea1a02dca511f@46.101.28.34:26656"
PEERS="34d4bfec8998a8fac6393a14c5ae151cf6a5762f@194.163.191.41:26656,49361422bfa3d57a14e318b6d87b40471b455092@65.21.193.112:26656"
sed -i.bak -e "s/^seeds *=.*/seeds = \"$SEEDS\"/; s/^persistent_peers *=.*/persistent_peers = \"$PEERS\"/" $HOME/.celestia-app/config/config.toml
external_address=$(wget -qO- eth0.me)
sed -i.bak -e "s/^external_address = \"\"/external_address = \"$external_address:26656\"/" $HOME/.celestia-app/config/config.toml
sed -i 's#"tcp://127.0.0.1:26657"#"tcp://0.0.0.0:26657"#g' $HOME/.celestia-app/config/config.toml
sed -i 's/timeout_commit = "5s"/timeout_commit = "15s"/g' $HOME/.celestia-app/config/config.toml
sed -i 's/index_all_keys = false/index_all_keys = true/g' $HOME/.celestia-app/config/config.toml
sed -i '/\[api\]/{:a;n;/enabled/s/false/true/;Ta};/\[api\]/{:a;n;/enable/s/false/true/;Ta;}' $HOME/.celestia-app/config/app.toml
celestia-appd unsafe-reset-all &>/dev/null
#wget -O $HOME/.celestia-app/config/addrbook.json "https://raw.githubusercontent.com/maxzonder/celestia/main/addrbook.json" &>/dev/null

celestia-appd config chain-id $CELESTIA_CHAIN
celestia-appd config keyring-backend test

sudo tee <<EOF >/dev/null /etc/systemd/journald.conf
Storage=persistent
EOF
sudo systemctl restart systemd-journald

sudo tee <<EOF >/dev/null /etc/systemd/system/celestia-appd.service
[Unit]
  Description=celestia-appd Cosmos daemon
  After=network-online.target
[Service]
  User=$USER
  ExecStart=$(which celestia-appd) start
  Restart=on-failure
  RestartSec=3
  LimitNOFILE=4096
[Install]
  WantedBy=multi-user.target
EOF

sudo systemctl enable celestia-appd &>/dev/null
sudo systemctl daemon-reload
sudo systemctl restart celestia-appd

echo "Validator Node $CELESTIA_NODENAME успешно установлена"
echo "-----------------------------------------------------------------------------"
