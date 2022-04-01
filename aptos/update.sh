#!/bin/bash
echo "-----------------------------------------------------------------------------"
curl -s https://raw.githubusercontent.com/razumv/helpers/main/doubletop.sh | bash
echo "-----------------------------------------------------------------------------"
echo -e "\e[1m\e[32mНачинаем обновление... \e[0m" && sleep 1
echo "-----------------------------------------------------------------------------"
echo -e "\e[1m\e[32m1. Стопаем Aptos... \e[0m" && sleep 1
echo "-----------------------------------------------------------------------------"
sudo systemctl stop aptos
echo "-----------------------------------------------------------------------------"
echo -e "\e[1m\e[32m2. Скачиваем конфиги... \e[0m" && sleep 1
echo "-----------------------------------------------------------------------------"
rm -f $HOME/aptos/waypoint.txt $HOME/aptos/genesis.blob
wget https://devnet.aptoslabs.com/genesis.blob
wget https://devnet.aptoslabs.com/waypoint.txt
echo "-----------------------------------------------------------------------------"
echo -e "\e[1m\e[32m3. Обновляем код... \e[0m" && sleep 1
echo "-----------------------------------------------------------------------------"
if ! command -v aptos-operational-tool &> /dev/null
then
  git clone https://github.com/aptos-labs/aptos-core.git  &> /dev/null
  cd $HOME/aptos-core  &> /dev/null
  git fetch &>/dev/null
  git checkout origin/devnet &>/dev/null
  echo y | ./scripts/dev_setup.sh  &> /dev/null
  source ~/.cargo/env
  cargo build -p aptos-operational-tool --release  &> /dev/null
  mv $HOME/aptos-core/target/release/aptos-operational-tool /usr/local/bin  &> /dev/null
else
  cd $HOME/aptos-core
  git fetch && git pull
  cargo build -p aptos-operational-tool --release  &> /dev/null
  mv $HOME/aptos-core/target/release/aptos-operational-tool /usr/local/bin  &> /dev/null
fi
if ! command -v aptos-node &> /dev/null
then
  git clone https://github.com/aptos-labs/aptos-core.git  &> /dev/null
  cd $HOME/aptos-core  &> /dev/null
  git fetch &>/dev/null
  git checkout origin/devnet &>/dev/null
  echo y | ./scripts/dev_setup.sh  &> /dev/null
  source ~/.cargo/env
  cargo build -p aptos-node --release &> /dev/null
  mv $HOME/aptos-core/target/release/aptos-node /usr/local/bin  &> /dev/null
else
  cd $HOME/aptos-core
  git fetch && git pull
  cargo build -p aptos-node --release &> /dev/null
  mv $HOME/aptos-core/target/release/aptos-node /usr/local/bin  &> /dev/null
fi
# echo "-----------------------------------------------------------------------------"
# echo -e "\e[1m\e[32m3. Очищаем бд... \e[0m" && sleep 1
# echo "-----------------------------------------------------------------------------"
# rm -rf $HOME/aptos/data
# echo "бд удалена"
echo "-----------------------------------------------------------------------------"
echo -e "\e[1m\e[32m4. Запускаем Full-node... \e[0m" && sleep 1
echo "-----------------------------------------------------------------------------"
sudo systemctl start aptos
echo "-----------------------------------------------------------------------------"
echo -e "\e[1m\e[32mОбновление завершено... \e[0m" && sleep 1
echo "-----------------------------------------------------------------------------"
