#!/bin/bash
echo "-----------------------------------------------------------------------------"
curl -s https://raw.githubusercontent.com/razumv/helpers/main/doubletop.sh | bash
echo "-----------------------------------------------------------------------------"
docker pull kyve/evm:latest &>/dev/null
docker stop kyve &>/dev/null
docker container rm kyve &>/dev/null
docker run -d -it --restart=always \
--name kyve kyve/evm:latest \
--pool 0x753924e3f7bdbC877D1D81dD82A61c29a165814E \
--private-key `cat $HOME/metamask.txt` \
--stake 101 &>/dev/null
echo Обновление завершено
