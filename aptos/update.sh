#!/bin/bash
function install_deps {
  curl -s https://raw.githubusercontent.com/razumv/helpers/main/tools/install_ufw.sh | bash &>/dev/null
  curl -s https://raw.githubusercontent.com/razumv/helpers/main/tools/install_rust.sh | bash &>/dev/null
  sudo apt-get install jq mc wget git -y &>/dev/null
  sudo wget -qO /usr/local/bin/yq https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64 &>/dev/null
  sudo chmod a+x /usr/local/bin/yq
}

function check_stop_old_docker {
  ps=$(docker ps -a | grep "aptos-fullnode-1")
  if [ -z "$ps" ];
  then
  echo "Старая версия на docker не обнаружена"
  else
    echo "Старая версия на docker обнаружена,удаляем и переходим на systemd"
    docker compose -f $HOME/aptos/docker-compose.yaml down
    docker volume rm aptos_db
    docker rmi -f $(docker images | grep aptos | awk '{print $3}')
    echo "Удалено, продолжаем обновление"
  fi
}

function source_code {
  cd $HOME
  git clone https://github.com/aptos-labs/aptos-core.git
  cd $HOME/aptos-core
  git fetch
  git checkout origin/devnet
  echo y | ./scripts/dev_setup.sh
  source ~/.cargo/env
}

function fetch_code {
  cd $HOME/aptos-core
  git fetch && git pull origin devnet
}

function update_genesis_files {
  cd $HOME/aptos/
  rm -f $HOME/aptos/waypoint.txt $HOME/aptos/genesis.blob
  wget https://devnet.aptoslabs.com/genesis.blob
  wget https://devnet.aptoslabs.com/waypoint.txt
}

function build_tools {
  cargo build -p aptos-operational-tool --release
  mv $HOME/aptos-core/target/release/aptos-operational-tool /usr/local/bin
}

function build_node {
  cargo build -p aptos-node --release
  mv $HOME/aptos-core/target/release/aptos-node /usr/local/bin
}

function wget_tools {
  sudo wget -O /usr/local/bin/aptos-operational-tool http://65.21.193.112/aptos-operational-tool
  chmod +x /usr/local/bin/aptos-operational-tool
}

function wget_node {
  sudo wget -O /usr/local/bin/aptos-node http://65.21.193.112/aptos-node
  chmod +x /usr/local/bin/aptos-node
}

function get_vars {
  PEER_ID=$(sed -n 2p $HOME/aptos/identity/peer-info.yaml | sed 's/.$//' | sed 's/://g')
  PRIVATE_KEY=$(cat $HOME/aptos/identity/private-key.txt)
  WAYPOINT=$(cat $HOME/aptos/waypoint.txt)
}

function fix_config {
  cp $HOME/aptos-core/config/src/config/test_data/public_full_node.yaml $HOME/aptos/public_full_node.yaml
  /usr/local/bin/yq e -i '.full_node_networks[] +=  { "identity": {"type": "from_config", "key": "'$PRIVATE_KEY'", "peer_id": "'$PEER_ID'"} }' $HOME/aptos/public_full_node.yaml
  sed -i 's|127.0.0.1|0.0.0.0|' $HOME/aptos/public_full_node.yaml
  sed -i -e "s|genesis_file_location: .*|genesis_file_location: \"$HOME\/aptos\/genesis.blob\"|" $HOME/aptos/public_full_node.yaml
  sed -i -e "s|data_dir: .*|data_dir: \"$HOME\/aptos\/data\"|" $HOME/aptos/public_full_node.yaml
  sed -i -e "s|0:01234567890ABCDEFFEDCA098765421001234567890ABCDEFFEDCA0987654210|$WAYPOINT|" $HOME/aptos/public_full_node.yaml
}

function delete_old_database {
  rm -rf $HOME/aptos/data/
}

function fix_journal {
  sudo tee <<EOF >/dev/null /etc/systemd/journald.conf
  Storage=persistent
EOF
  sudo systemctl restart systemd-journald
}

function bin_service {
  sudo tee <<EOF >/dev/null /etc/systemd/system/aptos.service
  [Unit]
    Description=Aptos daemon
    After=network-online.target
  [Service]
    User=$USER
    ExecStart=/usr/local/bin/aptos-node -f $HOME/aptos/public_full_node.yaml
    Restart=on-failure
    RestartSec=3
    LimitNOFILE=4096
  [Install]
    WantedBy=multi-user.target
EOF

  sudo systemctl enable aptos
  sudo systemctl daemon-reload
  sudo systemctl restart aptos
  echo "Сервис обновлен, демон перезагружен"
}

function logo {
  curl -s https://raw.githubusercontent.com/razumv/helpers/main/doubletop.sh | bash
}

function line {
  echo "-----------------------------------------------------------------------------"
}

function colors {
  GREEN="\e[1m\e[32m"
  RED="\e[1m\e[39m"
  NORMAL="\e[0m"
}

colors
line
logo
line
echo -e "${GREEN}Начинаем обновление... ${NORMAL}" && sleep 1
line
echo -e "${GREEN}1. Стопаем Aptos... ${NORMAL}" && sleep 1
line
check_stop_old_docker
sudo systemctl stop aptos  &> /dev/null
line
echo -e "${GREEN}2. Скачиваем конфиги... ${NORMAL}" && sleep 1
line
update_genesis_files
line
echo -e "${GREEN}3. Обновляем код... ${NORMAL}" && sleep 1
line
if ! command -v aptos-operational-tool &> /dev/null
then
  source_code
  # build_tools
  wget_tools
else
  fetch_code
  # build_tools
  wget_tools
fi
if ! command -v aptos-node &> /dev/null
then
  source_code
  # build_node
  wget_node
else
  fetch_code
  # build_node
  wget_node
fi
line
echo -e "${GREEN}4. Фиксим конфиг... ${NORMAL}" && sleep 1
line
get_vars
fix_config
delete_old_database
line
echo -e "${GREEN}5. Запускаем Full-node... ${NORMAL}" && sleep 1
line
fix_journal
bin_service
line
echo -e "${GREEN}Обновление завершено... ${NORMAL}" && sleep 1
line
