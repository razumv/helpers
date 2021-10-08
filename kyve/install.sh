#!/bin/bash

if [ ! $KYVE_NODENAME ]; then
	read -p "Enter node name: " KYVE_NODENAME
fi
echo 'Your node name: ' $KYVE_NODENAME
sleep 1
echo 'export KYVE_NODENAME='$KYVE_NODENAME >> $HOME/.profile
source .profile
sleep 1

curl -s https://raw.githubusercontent.com/razumv/helpers/main/tools/install_docker.sh | bash

git clone https://github.com/KYVENetwork/kyve.git

tee <<EOF >/dev/null $HOME/kyve/integrations/config.json
{
  "pools": {
    "0": 1,
    "2": 10
  }
}
EOF

tee <<EOF >/dev/null $HOME/kyve/integrations/node/.env
CONFIG=config.json
WALLET=arweave.json
SEND_STATISTICS=true
EOF

cp $HOME/arweave.json $HOME/kyve/integrations/node/

cd $HOME/kyve/integrations/node
docker build -t kyve-node:latest .
docker run --name $KYVE_NODENAME kyve-node:latest
