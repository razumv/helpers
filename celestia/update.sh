#!/bin/bash
echo "-----------------------------------------------------------------------------"
curl -s https://raw.githubusercontent.com/razumv/helpers/main/doubletop.sh | bash
echo "-----------------------------------------------------------------------------"
cd $HOME
ver="1.17.2"
wget "https://golang.org/dl/go$ver.linux-amd64.tar.gz" &>/dev/null
sudo rm -rf /usr/local/go
sudo tar -C /usr/local -xzf "go$ver.linux-amd64.tar.gz" &>/dev/null
rm "go$ver.linux-amd64.tar.gz"
echo "export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin" >> $HOME/.bash_profile &>/dev/null
source $HOME/.bash_profile
echo "Софт успешно обновлен, начинаем обновление репрозитория"
echo "-----------------------------------------------------------------------------"
sudo systemctl stop celestia-appd celestia-full celestia-light
cd $HOME
rm -rf celestia-node &>/dev/null
git clone https://github.com/celestiaorg/celestia-node.git &>/dev/null
echo "Репозиторий успешно обновлен, начинаем билд"
echo "-----------------------------------------------------------------------------"
cd celestia-node
git checkout v0.2.0
make install &>/dev/null
echo "Билд завершен успешно"
echo "-----------------------------------------------------------------------------"
mv $HOME/.celestia-full $HOME/.celestia-bridge
source $HOME/.profile

sudo tee /etc/systemd/system/celestia-bridge.service > /dev/null <<EOF
[Unit]
  Description=celestia-bridge
  After=network-online.target
[Service]
  User=$USER
  ExecStart=$(which celestia) bridge start
  Restart=on-failure
  RestartSec=10
  LimitNOFILE=4096
[Install]
  WantedBy=multi-user.target
EOF

sudo systemctl enable celestia-bridge &>/dev/null
sudo systemctl daemon-reload
sudo systemctl restart celestia-bridge celestia-appd celestia-light

echo "Нода обновилена и запущена"
echo "-----------------------------------------------------------------------------"
