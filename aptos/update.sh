#!/bin/bash

function add_layout {
  ROOT_KEY=F22409A93D1CD12D2FC92B5F8EB84CDCD24C348E32B3E7A720F3D2E288E63394
  tee ${HOME}/${WORKSPACE}/layout.yaml > /dev/null <<EOF
---
root_key: "${ROOT_KEY}"
users:
  - ${aptos_username}
chain_id: 40
min_stake: 0
max_stake: 100000
min_lockup_duration_secs: 0
max_lockup_duration_secs: 2592000
epoch_duration_secs: 86400
initial_lockup_timestamp: 1656615600
min_price_per_gas_unit: 1
allow_new_validators: true
EOF
}

function download_framework {
  wget -qO ${HOME}/${WORKSPACE}/framework.zip https://github.com/aptos-labs/aptos-core/releases/download/aptos-framework-v0.1.0/framework.zip
  unzip -o ${HOME}/${WORKSPACE}/framework.zip -d ${HOME}/${WORKSPACE}/
  rm ${HOME}/${WORKSPACE}/framework.zip
}

source $HOME/.bash_profile
cd $HOME/$WORKSPACE
docker-compose pull
docker-compose down
add_layout
download_framework
docker-compose up -d
