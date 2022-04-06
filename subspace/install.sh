#!/bin/bash

function colors {
  GREEN="\e[1m\e[32m"
  RED="\e[1m\e[39m"
  NORMAL="\e[0m"
}

function logo {
  curl -s https://raw.githubusercontent.com/razumv/helpers/main/doubletop.sh | bash
}

function line_1 {
  echo -e "${GREEN}-----------------------------------------------------------------------------${NORMAL}"
}

function line_2 {
  echo -e "${RED}##############################################################################${NORMAL}"
}

function install_tools {
  sudo apt update && sudo apt install mc wget htop jq -y
}

function install_docker {
  curl -s https://raw.githubusercontent.com/razumv/helpers/main/tools/install_docker.sh | bash
}

function install_ufw {
  curl -s https://raw.githubusercontent.com/razumv/helpers/main/tools/install_ufw.sh | bash
}

function read_nodename {
  echo -e "Enter your node name(random name for telemetry)"
  line
  read SUBSPACE_NODENAME
}

function read_wallet {
  echo -e "Enter your polkadot.js extension address"
  line
  read WALLET_ADDRESS
}

function eof_docker_compose {
  mkdir -p $HOME/subspace/
  sudo tee <<EOF >/dev/null $HOME/subspace/docker-compose.yml
  version: "3.7"
  services:
    node:
      image: subspacelabs/subspace-node
      networks:
        - default
        - subspace
      volumes:
        - source: subspace-node
          target: /var/subspace
          type: volume
      command: [
        "--validator",
        "--force-authoring",
        "--chain", "testnet",
        "--base-path", "/var/subspace",
        "--ws-external",
        "--bootnodes", "/dns/farm-rpc.subspace.network/tcp/30333/p2p/12D3KooWPjMZuSYj35ehced2MTJFf95upwpHKgKUrFRfHwohzJXr",
        "--name", "$SUBSPACE_NODENAME",
        "--telemetry-url", "wss://telemetry.polkadot.io/submit/ 1"
      ]
    farmer:
      image: subspacelabs/subspace-farmer
      networks:
        - default
      volumes:
        - source: subspace-farmer
          target: /var/subspace
          type: volume
      restart: always
      command: [
        "farm",
        "--node-rpc-url", "ws://node:9944",
        "--reward-address", "$WALLET_ADDRESS"
      ]

  networks:
    subspace:
      external: true
      name: subspace

  volumes:
    subspace-node:
    subspace-farmer:
EOF
}

function docker_compose_pull {
  docker network create subspace
  docker-compose -f $HOME/subspace/docker-compose.yml pull
}

function docker_compose_up {
  docker-compose -f $HOME/subspace/docker-compose.yml up -d
}

function echo_info {
  echo -e "${GREEN}Для остановки ноды и фармера subspace: ${NORMAL}"
  echo -e "${RED}   docker-compose -f $HOME/subspace/docker-compose.yml down \n ${NORMAL}"
  echo -e "${GREEN}Для запуска ноды и фармера subspace: ${NORMAL}"
  echo -e "${RED}   docker-compose -f $HOME/subspace/docker-compose.yml up -d \n ${NORMAL}"
  echo -e "${GREEN}Для перезагрузки ноды subspace: ${NORMAL}"
  echo -e "${RED}   docker-compose -f $HOME/subspace/docker-compose.yml restart node \n ${NORMAL}"
  echo -e "${GREEN}Для перезагрузки фармера subspace: ${NORMAL}"
  echo -e "${RED}   docker-compose -f $HOME/subspace/docker-compose.yml restart farmer \n ${NORMAL}"
  echo -e "${GREEN}Для проверки логов ноды выполняем команду: ${NORMAL}"
  echo -e "${RED}   docker-compose -f $HOME/subspace/docker-compose.yml logs -f --tail=100 node \n ${NORMAL}"
  echo -e "${GREEN}Для проверки логов фармера выполняем команду: ${NORMAL}"
  echo -e "${RED}   docker-compose -f $HOME/subspace/docker-compose.yml logs -f --tail=100 farmer \n ${NORMAL}"
}

colors
line_1
logo
line_2
read_nodename
line_2
read_wallet
line_2
echo -e "Установка tools, ufw, docker"
line_1
install_tools
install_ufw
install_docker
line_1
echo -e "Скачиваем docker образы"
line
eof_docker_compose
docker_compose_pull
line_1
echo -e "Запускаем docker контейнеры для node and farmer Subspace"
line_1
docker_compose_up
line_2
echo_info
line_2
