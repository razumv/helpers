#!/bin/bash

#add ufw rules
curl -s https://raw.githubusercontent.com/razumv/helpers/main/tools/install_ufw.sh | bash

sudo systemctl stop zeitgeist

# rm -rf $HOME/.local/share/zeitgeist/chains/battery_park/db/
rm -f $HOME/zeitgeist/target/release/zeitgeist

wget https://github.com/zeitgeistpm/zeitgeist/releases/download/v0.2.1/zeitgeist_parachain -O $HOME/zeitgeist/target/release/zeitgeist
curl -o $HOME/battery-station-relay.json https://raw.githubusercontent.com/zeitgeistpm/polkadot/battery-station-relay/node/service/res/battery-station-relay.json
chmod +x $HOME/zeitgeist/target/release/zeitgeist
# mkdir -p $HOME/.local/share/zeitgeist/chains/battery_station_mainnet/
# cp -r $HOME/.local/share/zeitgeist/chains/battery_park/keystore $HOME/.local/share/zeitgeist/chains/battery_station_mainnet/
# cp -r $HOME/.local/share/zeitgeist/chains/battery_park/keystore $HOME/.local/share/zeitgeist/polkadot/chains/rococo_battery_station_relay_testnet/
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
Nice=0
ExecStart=$HOME/zeitgeist/target/release/zeitgeist \
    --bootnodes=/ip4/45.33.117.205/tcp/30001/p2p/12D3KooWBMSGsvMa2A7A9PA2CptRFg9UFaWmNgcaXRxr1pE1jbe9 \
    --chain=battery_station \
    --name="$NODENAME | DOUBLETOP" \
    --parachain-id=2050 \
    --port=30333 \
    --rpc-port=9933 \
    --ws-port=9944 \
    --rpc-external \
    --ws-external \
    --rpc-cors=all \
    -- \
    --bootnodes=/ip4/45.33.117.205/tcp/31001/p2p/12D3KooWHgbvdWFwNQiUPbqncwPmGCHKE8gUQLbzbCzaVbkJ1crJ \
    --bootnodes=/ip4/45.33.117.205/tcp/31002/p2p/12D3KooWE5KxMrfJLWCpaJmAPLWDm9rS612VcZg2JP6AYgxrGuuE \
    --chain=$HOME/battery-station-relay.json \
    --port=30334 \
    --rpc-port=9934 \
    --ws-port=9945
Restart=always
RestartSec=10
LimitNOFILE=10000
[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable zeitgeist
sudo systemctl restart zeitgeist
