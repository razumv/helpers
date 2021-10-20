#!/bin/bash

#add ufw rules
curl -s https://raw.githubusercontent.com/razumv/helpers/main/tools/install_ufw.sh | bash

sudo systemctl stop zeitgeist

rm -rf $HOME/.local/share/zeitgeist/chains/battery_park/db/

wget https://github.com/zeitgeistpm/zeitgeist/releases/download/v0.2.0/zeitgeist -O $HOME/zeitgeist/target/release/zeitgeist
curl -o battery-station-relay.json https://raw.githubusercontent.com/zeitgeistpm/polkadot/battery-station-relay/node/service/res/battery-station-relay.json

sudo tee <<EOF >/dev/null /etc/systemd/journald.conf
Storage=persistent
EOF
sudo systemctl restart systemd-journald

sudo tee <<EOF >/dev/null /etc/systemd/system/zeitgeist.service
[Unit]
Description=Zeitgeist Node
After=network-online.target
[Service]
User=$USER
ExecStart=$HOME/zeitgeist/target/release/zeitgeist --chain battery_station \
--bootnodes=/ip4/45.33.117.205/tcp/30001/p2p/12D3KooWBMSGsvMa2A7A9PA2CptRFg9UFaWmNgcaXRxr1pE1jbe9 \
--bootnodes=/ip4/45.33.117.205/tcp/31001/p2p/12D3KooWHgbvdWFwNQiUPbqncwPmGCHKE8gUQLbzbCzaVbkJ1crJ \
--bootnodes=/ip4/45.33.117.205/tcp/31002/p2p/12D3KooWE5KxMrfJLWCpaJmAPLWDm9rS612VcZg2JP6AYgxrGuuE \
--chain=$HOME/battery-station-relay.json \
--name "$NODENAME | DOUBLETOP" --validator
Restart=always
RestartSec=10
LimitNOFILE=10000
[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable zeitgeist
sudo systemctl restart zeitgeist
