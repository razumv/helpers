#!/bin/bash
cd $HOME
wallet_name=`docker exec ironfish ./bin/run accounts:which`
docker exec ironfish ./bin/run accounts:export $wallet_name wallet
docker cp ironfish:/usr/src/app/wallet .
docker-compose down
docker-compose pull
docker-compose up -d
docker exec ironfish-miner ./bin/run reset --confirm
docker-compose restart
docker cp wallet ironfish:/usr/src/app/wallet
docker exec ironfish ./bin/run accounts:import wallet
docker exec ironfish ./bin/run accounts:use $wallet_name
