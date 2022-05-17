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
  sed -i 's/snapshot-2022-may-03/snapshot-2022-mar-09/g' $HOME/subspace_docker/docker-compose.yml
  docker-compose pull
}

function p {
  docker volume rm subspace_docker_subspace-farmer subspace_docker_subspace-node
}

colors
line
logo
line
