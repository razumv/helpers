#!/bin/bash

sudo apt update
sudo apt-get install curl gnupg -y
wget -qO- https://raw.githubusercontent.com/creationix/nvm/v0.33.8/install.sh | bash
source ~/.profile
sleep 1
source ~/.bashrc
sleep 1
nvm install 14.18.0
nvm use 14.18.0
curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
sudo apt update
sudo apt install --no-install-recommends yarn
yarn --version
npm --version
node --version
