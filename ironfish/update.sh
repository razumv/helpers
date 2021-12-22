#!/bin/bash
echo "-----------------------------------------------------------------------------"
curl -s https://raw.githubusercontent.com/razumv/helpers/main/doubletop.sh | bash
echo "-----------------------------------------------------------------------------"
sudo apt update &>/dev/null
sudo apt install jq -y &>/dev/null
blockGraffiti=`docker exec ironfish ./bin/run config:show | jq -r .blockGraffiti`
nodeName=`docker exec ironfish ./bin/run config:show | jq -r .nodeName`

cd $HOME
var=`docker-compose logs --tail=1000 ironfish | grep "Added block to fork seq"`

if [ -z "$var" ]
then
  echo "Ваш майнер не в форке, выполняем обновление"
  echo "-----------------------------------------------------------------------------"
  docker-compose down
  docker-compose pull
  docker-compose up -d
else
  echo "Ваш майнер в форке, выполняем сброс и обновление"
  echo "-----------------------------------------------------------------------------"
  wallet_name=`docker exec ironfish ./bin/run accounts:which` &>/dev/null
  docker exec ironfish rm -f wallet &>/dev/null
  docker exec ironfish ./bin/run accounts:export $wallet_name wallet &>/dev/null
  docker cp ironfish:/usr/src/app/wallet .
  docker-compose down
  docker-compose pull
  rm -rf $HOME/.ironfish
  docker-compose up -d &>/dev/null
  docker cp wallet ironfish:/usr/src/app/wallet
  docker exec ironfish ./bin/run accounts:import wallet
  docker exec ironfish ./bin/run accounts:use $wallet_name &>/dev/null
  docker exec ironfish ./bin/run config:set nodeName $nodeName
  docker exec ironfish ./bin/run config:set blockGraffiti $blockGraffiti
  docker-compose restart
fi
echo "Обновление завершено"
echo "-----------------------------------------------------------------------------"
