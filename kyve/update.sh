#!/bin/bash
echo "-----------------------------------------------------------------------------"
curl -s https://raw.githubusercontent.com/razumv/helpers/main/doubletop.sh | bash
echo "-----------------------------------------------------------------------------"
docker pull kyve/evm:latest &>/dev/null
docker stop kyve &>/dev/null
docker container rm kyve &>/dev/null
docker run -d -it --restart=always \
--name kyve kyve/evm:latest \
--pool 0xd1EAe9CC4C0cC8D82c5800e2dAE972A70f2C4d0d \
--private-key `cat $HOME/metamask.txt` \
--stake 101 &>/dev/null
echo Обновление завершено
