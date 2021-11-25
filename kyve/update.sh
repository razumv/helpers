#!/bin/bash
echo "-----------------------------------------------------------------------------"
curl -s https://raw.githubusercontent.com/razumv/helpers/main/doubletop.sh | bash
echo "-----------------------------------------------------------------------------"
docker pull kyve/evm:latest &>/dev/null
docker pull kyve/cosmos:latest &>/dev/null
docker pull kyve/solana-snapshots:latest &>/dev/null
docker pull kyve/celo:latest &>/dev/null

docker stop kyve kyve-avalanche kyve-moonriver kyve-cosmos kyve-solana kyve-celo &>/dev/null
docker container rm kyve kyve-avalanche kyve-moonriver kyve-cosmos kyve-solana kyve-celo &>/dev/null

docker run -d -it --restart=always \
--name kyve-avalanche kyve/evm:latest \
--pool 0x464200b29738367366FDb4c45f3b8fb582AE0Bf8 \
--private-key `cat $HOME/metamask.txt` \
--stake 150 \
-e https://rpc.testnet.moonbeam.network &>/dev/null

docker run -d -it --restart=always \
--name kyve-moonriver kyve/evm:latest \
--pool 0x610D55fA573Bce4D2d36e8ADAAee517B785a69dF \
--private-key `cat $HOME/metamask.txt` \
--stake 150 \
-e https://rpc.testnet.moonbeam.network &>/dev/null

docker run -d -it --restart=always \
--name kyve-cosmos kyve/cosmos:latest \
--pool 0x7Bb18C81BBA6B8dE8C17B97d78B65327024F681f \
--private-key `cat $HOME/metamask.txt` \
--stake 150 \
-e https://rpc.testnet.moonbeam.network &>/dev/null

docker run -d -it --restart=always \
--name kyve-solana kyve/solana-snapshots:latest \
--pool 0xB7CcAc5BCB7DBa5c66dF42C6872d2f6Dbf7529a7 \
--private-key `cat $HOME/metamask.txt` \
--stake 150 \
-e https://rpc.testnet.moonbeam.network &>/dev/null

docker run -d -it --restart=always \
--name kyve-celo kyve/celo:latest \
--pool 0x987aee4981CB2dd4759A76Fde56E77121b90929a \
--private-key `cat $HOME/metamask.txt` \
--stake 150 \
-e https://rpc.testnet.moonbeam.network &>/dev/null



echo Обновление завершено
