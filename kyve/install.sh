#!/bin/bash

if [ ! $KYVE_NODENAME ]; then
	read -p "Введите имя ноды: " KYVE_NODENAME
fi
echo 'Ваше имя ноды: ' $KYVE_NODENAME
sleep 1
echo 'export KYVE_NODENAME='$KYVE_NODENAME >> $HOME/.profile
echo "------------------------------------------------------------------"
echo "Устанавливаем софт"
echo "------------------------------------------------------------------"
curl -s https://raw.githubusercontent.com/razumv/helpers/main/tools/install_ufw.sh | bash &>/dev/null
curl -s https://raw.githubusercontent.com/razumv/helpers/main/tools/install_docker.sh | bash &>/dev/null
curl -s https://raw.githubusercontent.com/razumv/helpers/main/tools/install_node14.sh | bash &>/dev/null
source .profile
source .bashrc
sleep 1
echo "------------------------------------------------------------------"
echo "Весь необходимый софт установлен"
echo "------------------------------------------------------------------"

if [ ! -d $HOME/kyve/ ]; then
  git clone https://github.com/KYVENetwork/kyve.git &>/dev/null
fi

if [ ! -e $HOME/metamask.txt ]; then
	echo "Файл с приватником от ММ отсутствует"
  exit 1
fi

if [ ! -e $HOME/arweave.json ]; then
	echo "Файл от расширения arweave.json отсутствует"
  exit 1
else
  cp $HOME/arweave.json $HOME/kyve/integrations/node/
fi

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
PK=`cat $HOME/metamask.txt`
EOF

echo "------------------------------------------------------------------"
echo "Репозиторий склонирован, конфиг на месте, начинаем билд приложения"
echo "------------------------------------------------------------------"

cd $HOME/kyve
yarn setup &>/dev/null

cd $HOME/kyve/integrations/node
yarn node:build &>/dev/null

docker run -d -it --restart=always --name=kyve kyve-node:latest

echo "------------------------------------------------------------------"
echo "Нода запущена, переходим к следующему пункту гайды"
echo "------------------------------------------------------------------"
