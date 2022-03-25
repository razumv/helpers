#!/bin/bash
echo "-----------------------------------------------------------------------------"
curl -s https://raw.githubusercontent.com/razumv/helpers/main/doubletop.sh | bash
echo "-----------------------------------------------------------------------------"
echo -e "\e[1m\e[32mНачинаем обновление... \e[0m" && sleep 1
echo "-----------------------------------------------------------------------------"
cd $HOME/aptos
echo -e "\e[1m\e[32m1. Обновляем докер образы... \e[0m" && sleep 1
echo "-----------------------------------------------------------------------------"
docker compose down
docker rmi -f aptoslab/tools:devnet aptoslab/validator:devnet
docker pull aptoslab/tools:devnet
docker pull aptoslab/validator:devnet
echo "-----------------------------------------------------------------------------"
echo -e "\e[1m\e[32m2. Скачиваем конфиги... \e[0m" && sleep 1
echo "-----------------------------------------------------------------------------"
rm -f $HOME/aptos/waypoint.txt $HOME/aptos/genesis.blob
wget https://devnet.aptoslabs.com/genesis.blob
wget https://devnet.aptoslabs.com/waypoint.txt
echo "-----------------------------------------------------------------------------"
echo -e "\e[1m\e[32m3. Очищаем бд... \e[0m" && sleep 1
echo "-----------------------------------------------------------------------------"
rm -rf /var/lib/docker/volumes/aptos_db/_data/*
echo "бд удалена"
echo "-----------------------------------------------------------------------------"
echo -e "\e[1m\e[32m4. Запускаем Full-node... \e[0m" && sleep 1
echo "-----------------------------------------------------------------------------"
docker compose up -d
echo "-----------------------------------------------------------------------------"
echo -e "\e[1m\e[32mОбновление завершено... \e[0m" && sleep 1
echo "-----------------------------------------------------------------------------"
