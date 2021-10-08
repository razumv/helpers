#!/bin/bash

if [ ! $KYVE_NODENAME ]; then
	read -p "Введите имя ноды: " KYVE_NODENAME
fi
echo 'Ваше имя ноды: ' $KYVE_NODENAME
sleep 1
echo 'export KYVE_NODENAME='$KYVE_NODENAME >> $HOME/.profile

curl -s https://raw.githubusercontent.com/razumv/helpers/main/tools/install_ufw.sh | bash
curl -s https://raw.githubusercontent.com/razumv/helpers/main/tools/install_docker.sh | bash
curl -s https://raw.githubusercontent.com/razumv/helpers/main/tools/install_nvm_yarn_npm.sh | bash
source .profile
source .bashrc
sleep 1

git clone https://github.com/KYVENetwork/kyve.git

tee <<EOF >/dev/null $HOME/kyve/integrations/config.json
{
  "pools": {
    "0xbBBfbE9A731634eDdf84C67A106CEE1F981F3f7e": 10
  }
}
EOF

tee <<EOF >/dev/null $HOME/kyve/integrations/node/.env
CONFIG=config.json
WALLET=arweave.json
SEND_STATISTICS=true
PK=private_key_from_metamask
EOF

if [ ! -e $HOME/arweave.json ]; then
	echo "Файл от расширения arweave.json отсутствует"
else
  cp $HOME/arweave.json $HOME/kyve/integrations/node/
fi

cd $HOME/kyve
yarn setup

cd $HOME/kyve/integrations/node
yarn node:build

docker run -d -it --restart=always --name=kyve kyve-node:latest
