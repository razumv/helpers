#!/bin/bash

function colors {
  GREEN="\e[32m"
  RED="\e[39m"
  NORMAL="\e[0m"
}

function logo {
  curl -s https://raw.githubusercontent.com/razumv/helpers/main/doubletop.sh | bash
}

function line {
  echo -e "${GREEN}-----------------------------------------------------------------------------${NORMAL}"
}

function update_subspace {
  cd $HOME/subspace_docker/
  docker-compose down
  docker volume rm subspace_docker_subspace-farmer subspace_docker_subspace-node
  sed -i 's/snapshot-2022-may-03/gemini-1b-2022-june-03/g' $HOME/subspace_docker/docker-compose.yml
  sed -i 's/testnet/gemini-1/g' $HOME/subspace_docker/docker-compose.yml
  docker-compose pull
  docker-compose up -d
}

colors
line
logo
line
update_subspace
echo -e "${GREEN}=== DONE ===${NORMAL}"
