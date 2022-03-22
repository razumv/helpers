#!/bin/bash
echo "-----------------------------------------------------------------------------"
curl -s https://raw.githubusercontent.com/razumv/helpers/main/doubletop.sh | bash
echo "-----------------------------------------------------------------------------"
docker pull kyve/evm:latest &>/dev/null


docker stop kyve kyve-avalanche kyve-moonriver kyve-cosmos kyve-solana kyve-celo &>/dev/null
docker container rm kyve kyve-avalanche kyve-moonriver kyve-cosmos kyve-solana kyve-celo &>/dev/null

docker run -d -it --restart=always \
--name kyve-avalanche kyve/evm:latest \
--pool 0x90a70AAE360e5E69C3cB466880f025985810f2c8 \
--private-key `cat $HOME/metamask.txt` \
--stake 150 \
--commission 10
-e https://rpc.testnet.moonbeam.network &>/dev/null

docker run -d -it --restart=always \
--name kyve-moonriver kyve/evm:latest \
--pool 0x7d5b80078480804C126363Cf1061C2DC6b9c1b22 \
--private-key `cat $HOME/metamask.txt` \
--stake 150 \
--commission 10
-e https://rpc.testnet.moonbeam.network &>/dev/null

docker run -d -it --restart=always \
--name kyve-aurora kyve/evm:latest \
--pool 0x7E6eb8D60409DC211218d6978E6FE69BB1DC1e24 \
--private-key `cat $HOME/metamask.txt` \
--stake 150 \
--commission 10
-e https://rpc.testnet.moonbeam.network &>/dev/null

docker run -d -it --restart=always \
--name kyve-moonbeam kyve/evm:latest \
--pool 0xFAA8A4d6AC08e8e470d5F4ED771D645d5CaF5957 \
--private-key `cat $HOME/metamask.txt` \
--stake 150 \
--commission 10
-e https://rpc.testnet.moonbeam.network &>/dev/null



echo Обновление завершено
