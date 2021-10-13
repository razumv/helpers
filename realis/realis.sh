#!/bin/bash

echo "-----------------------------------------------------------------------------"
curl -s https://raw.githubusercontent.com/razumv/helpers/main/doubletop.sh | bash
echo "-----------------------------------------------------------------------------"

if [ ! $REALIS_NODENAME ]; then
	read -p "Введите ваше имя ноды(придумайте, без спецсимволов - только буквы и цифры): " REALIS_NODENAME
fi
sleep 1
echo 'export REALIS_NODENAME='$REALIS_NODENAME >> $HOME/.profile

echo "-----------------------------------------------------------------------------"
echo "Устанавливаем софт"
echo "-----------------------------------------------------------------------------"
curl -s https://raw.githubusercontent.com/razumv/helpers/main/tools/install_ufw.sh | bash &>/dev/null
curl -s https://raw.githubusercontent.com/razumv/helpers/main/tools/install_rust.sh | bash &>/dev/null
sudo apt install --fix-broken -y &>/dev/null
sudo apt install nano mc -y &>/dev/null
source $HOME/.profile &>/dev/null
source $HOME/.bashrc &>/dev/null
source $HOME/.cargo/env &>/dev/null
sleep 1
rustup install nightly-2021-06-09 &>/dev/null
rustup target add wasm32-unknown-unknown --toolchain nightly-2021-06-09 &>/dev/null
echo "Весь необходимый софт установлен"
echo "-----------------------------------------------------------------------------"

if [ ! -d $HOME/Realis.Network/ ]; then
  git clone https://github.com/RealisNetwork/Realis.Network &>/dev/null
fi
echo "Репозиторий успешно склонирован, начинаем билд"
echo "-----------------------------------------------------------------------------"

cd $HOME/Realis.Network
$HOME/Realis.Network/scripts/build_separately.sh &>/dev/null
cargo build --release &>/dev/null
echo "Билд завершен успешно"
echo "-----------------------------------------------------------------------------"

sudo tee <<EOF >/dev/null /etc/systemd/journald.conf
Storage=persistent
EOF
sudo systemctl restart systemd-journald

sudo tee <<EOF >/dev/null /etc/systemd/system/realis.service
[Unit]
Description=Realis Node
After=network-online.target
[Service]
User=$USER
ExecStart=$HOME/Realis.Network/target/release/realis --chain=realis --validator --name "$REALIS_NODENAME"
Restart=always
RestartSec=10
LimitNOFILE=10000
[Install]
WantedBy=multi-user.target
EOF

echo "Сервисные файлы созданы успешно"
echo "-----------------------------------------------------------------------------"

sudo systemctl daemon-reload
sudo systemctl enable realis &>/dev/null
sudo systemctl restart realis

echo "Нода добавлена в автозагрузку на сервере, запущена"
echo "-----------------------------------------------------------------------------"
