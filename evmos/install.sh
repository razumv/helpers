#!/bin/bash
echo "-----------------------------------------------------------------------------"
curl -s https://raw.githubusercontent.com/razumv/helpers/main/doubletop.sh | bash
echo "-----------------------------------------------------------------------------"
if [ ! $EVMOS_NODENAME ]; then
	read -p "Введите ваше имя ноды(придумайте, без спецсимволов - только буквы и цифры): " EVMOS_NODENAME
fi
sleep 1
echo 'export EVMOS_NODENAME='$EVMOS_NODENAME >> $HOME/.profile
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
if [ ! -d $HOME/evmos/ ]; then
  git clone https://github.com/tharsis/evmos.git &>/dev/null
fi
echo "Репозиторий успешно склонирован, начинаем билд"
echo "-----------------------------------------------------------------------------"
cd $HOME/evmos
make install &>/dev/null
echo "Билд закончен"
echo "-----------------------------------------------------------------------------"
evmosd config chain-id evmos_9000-1 &>/dev/null
evmosd config keyring-backend file &>/dev/null
evmosd init "$EVMOS_NODENAME" --chain-id evmos_9000-1 &>/dev/null
wget -qO $HOME/.evmosd/config/genesis.json https://raw.githubusercontent.com/tharsis/testnets/main/arsia_mons/genesis.json &>/dev/null
live_peers="65516b494b5296d50161373b6e0b66ebe0fa7818@66.94.99.83:26656,148cce3293950d18a44225e9ee70ae1b8bb56299@161.97.74.88:26656,395d357ad66a187d02938c9801e811cbc4be7cd2@152.228.220.135:16657"
bootstrap_node="http://5.189.156.65:26657"; \
latest_height=`wget -qO- "${bootstrap_node}/block" | jq -r ".result.block.header.height"`; \
block_height=$((latest_height - 2000)); \
trust_hash=`wget -qO- "${bootstrap_node}/block?height=${block_height}" | jq -r ".result.block_id.hash"`; \
sed -i -e "s%^moniker *=.*%moniker = \"$EVMOS_NODENAME\"%; "\
"s%^seeds *=.*%seeds = \"c36cec90ded95d162b85f8ecd00ecd7c8849ca75@arsiamons.seed.evmos.org:26656,`wget -qO - https://raw.githubusercontent.com/tharsis/testnets/main/arsia_mons/seeds.txt | tr '\n' ',' | sed 's%,$%%'`\"%; "\
"s%^persistent_peers *=.*%persistent_peers = \"847e72f31e1f87e8059231b4b9e3302989c22d3a@5.189.156.65:26656,$live_peers,`wget -qO - https://raw.githubusercontent.com/tharsis/testnets/main/arsia_mons/peers.txt | tr '\n' ',' | sed 's%,$%%'`\"%; "\
"s%^enable *=.*%enable = true%; "\
"s%^rpc_servers *=.*%rpc_servers = \"${bootstrap_node},${bootstrap_node}\"%; "\
"s%^trust_height *=.*%trust_height = $block_height%; "\
"s%^trust_hash *=.*%trust_hash = \"$trust_hash\"%" $HOME/.evmosd/config/config.toml
echo "Конфигурирование ноды закончено"
echo "-----------------------------------------------------------------------------"
sudo tee <<EOF >/dev/null /etc/systemd/journald.conf
Storage=persistent
EOF
sudo systemctl restart systemd-journald

sudo tee <<EOF >/dev/null /etc/systemd/system/evmos.service
[Unit]
Description=Evmos Node
After=network-online.target
[Service]
User=$USER
ExecStart=$(which evmosd) start
Restart=always
RestartSec=10
LimitNOFILE=10000
[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable evmos
sudo systemctl start evmos
echo "Сервисные файлы созданы успешно, возвращаемся к гайду"
echo "-----------------------------------------------------------------------------"
