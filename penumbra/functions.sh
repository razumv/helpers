#!/bin/bash

curl -s https://raw.githubusercontent.com/razumv/helpers/main/functions.sh | bash

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
  git checkout 006-orthosie
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
