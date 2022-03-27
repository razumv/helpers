#/bin/bash

curl -s https://github.com/razumv/helpers/blob/main/tools/install_go.sh | bash

export release=0.3.0
# wget https://github.com/solarlabsteam/cosmos-exporter/releases/download/v"$release"/cosmos-exporter_"$release"_Linux_arm64.tar.gz
# tar xvfz cosmos-exporter_"$release"_Linux_arm64.tar.gz
# rm -f cosmos-exporter_"$release"_Linux_arm64.tar.gz
cd $HOME
git clone https://github.com/solarlabsteam/cosmos-exporter
cd $HOME/cosmos-exporter
git checkout v0.3.0
go build

sudo cp ./cosmos-exporter /usr/bin

sudo tee <<EOF >/dev/null /etc/systemd/system/cosmos-exporter.service
[Unit]
Description=Cosmos Exporter
After=network-online.target

[Service]
User=$USER
TimeoutStartSec=0
CPUWeight=95
IOWeight=95
ExecStart=/usr/bin/cosmos-exporter
Restart=always
RestartSec=2
LimitNOFILE=800000
KillSignal=SIGTERM

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable cosmos-exporter
sudo systemctl restart cosmos-exporter
