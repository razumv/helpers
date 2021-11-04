#!/bin/bash
echo "-----------------------------------------------------------------------------"
curl -s https://raw.githubusercontent.com/razumv/helpers/main/doubletop.sh | bash
echo "-----------------------------------------------------------------------------"

echo "Устанавливаем софт"
echo "-----------------------------------------------------------------------------"
curl -s https://raw.githubusercontent.com/razumv/helpers/main/tools/install_ufw.sh | bash &>/dev/null
curl -s https://raw.githubusercontent.com/razumv/helpers/main/tools/install_docker.sh | bash &>/dev/null
# curl -s https://raw.githubusercontent.com/razumv/helpers/main/tools/install_node14.sh | bash &>/dev/null
sudo apt install --fix-broken -y &>/dev/null
sudo apt install nano mc -y &>/dev/null
source .profile
source .bashrc
sleep 1
echo "Весь необходимый софт установлен"
echo "-----------------------------------------------------------------------------"

# if [ ! -d $HOME/kyve/ ]; then
#   git clone https://github.com/KYVENetwork/kyve.git &>/dev/null
# fi

if [ ! -e $HOME/metamask.txt ]; then
	echo "Файл с приватником от ММ отсутствует"
  exit 1
fi

# if [ ! -e $HOME/arweave.json ]; then
# 	echo "Файл от расширения arweave.json отсутствует"
#   exit 1
# else
#   cp $HOME/arweave.json $HOME/kyve/integrations/node/
# fi

# tee <<EOF >/dev/null $HOME/kyve/integrations/node/config.json
# {
#   "pools": {
#     "0xbBBfbE9A731634eDdf84C67A106CEE1F981F3f7e": 10
#   }
# }
# EOF

# tee <<EOF >/dev/null $HOME/kyve/integrations/node/.env
# CONFIG=config.json
# WALLET=arweave.json
# SEND_STATISTICS=true
# PK=`cat $HOME/metamask.txt`
# EOF
#
# echo "Репозиторий склонирован, конфиг на месте, начинаем билд приложения"
# echo "-----------------------------------------------------------------------------"

# cd $HOME/kyve
# yarn setup &>/dev/null
#
# cd $HOME/kyve/integrations/node
# yarn node:build &>/dev/null
#
# docker rm -f kyve &>/dev/null
# docker run -d -it --restart=always --name=kyve kyve-node:latest &>/dev/null
#docker pull kyve/evm:latest &>/dev/null
docker stop kyve &>/dev/null
docker container rm kyve &>/dev/null
docker run -d -it --restart=always \
--name kyve-avalanche kyve/evm:latest \
--pool 0xd1EAe9CC4C0cC8D82c5800e2dAE972A70f2C4d0d \
--private-key `cat $HOME/metamask.txt` \
--stake 101 \
-e https://rpc.testnet.moonbeam.network &>/dev/null

docker run -d -it --restart=always \
--name kyve-moonriver kyve/evm:latest \
--pool 0x5A679d476757C18Ec49dfB6c3c3511c8E8a76906 \
--private-key `cat $HOME/metamask.txt` \
--stake 101 \
-e https://rpc.testnet.moonbeam.network &>/dev/null

docker run -d -it --restart=always \
--name kyve-cosmos kyve/cosmos:latest \
--pool 0x83748889798a93e4a816a6a9D2ecD40377D5530B \
--private-key `cat $HOME/metamask.txt` \
--stake 101 \
-e https://rpc.testnet.moonbeam.network &>/dev/null

echo "Нода запущена, переходим к следующему пункту гайда"
echo "-----------------------------------------------------------------------------"
