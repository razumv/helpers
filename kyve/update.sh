#!/bin/bash
echo "-----------------------------------------------------------------------------"
curl -s https://raw.githubusercontent.com/razumv/helpers/main/doubletop.sh | bash
echo "-----------------------------------------------------------------------------"
docker pull kyve/evm:latest &>/dev/null
docker pull kyve/cosmos:latest &>/dev/null
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
echo Обновление завершено
