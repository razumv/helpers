#!/bin/bash

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

function install_tools {
  curl -s https://raw.githubusercontent.com/razumv/helpers/main/tools/install_ufw.sh | bash &>/dev/null
  curl -s https://raw.githubusercontent.com/razumv/helpers/main/tools/install_rust.sh | bash &>/dev/null
  source ~/.cargo/env
  rustup detault nightly
  sleep 1
}

function source_git {
  if [ ! -d $HOME/penumbra/ ]; then
    git clone https://github.com/penumbra-zone/penumbra
  fi
  cd $HOME/penumbra
  git fetch
  git checkout 015-ersa-v2
}

function build_penumbra {
  if [ ! -d $HOME/penumbra/ ]; then
    cd $HOME/penumbra/
    cargo build --release --bin pcli
  else
    source_git
    cd $HOME/penumbra/
    cargo build --release --bin pcli
  fi
}

function generate_wallet {
  cd $HOME/penumbra/
  cargo run --quiet --release --bin pcli wallet generate
}

function reset_wallet {
  cd $HOME/penumbra/
  cargo run --quiet --release --bin pcli wallet reset
}

function rust_update {
  rustup update
  rustup default nightly
}


colors

line
logo
line
echo -e "${RED}Начинаем обновление ${NORMAL}"
line
echo -e "${GREEN}1/2 Обновляем репозиторий ${NORMAL}"
source_git
line
echo -e "${GREEN}2/2 Начинаем билд ${NORMAL}"
rust_update
line
build_penumbra
reset_wallet
line
echo -e "${RED}Скрипт завершил свою работу ${NORMAL}"
