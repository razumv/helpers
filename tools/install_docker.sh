#!/bin/bash
sudo apt update
sudo apt install wget -y
wget -O get-docker.sh https://get.docker.com
sudo sh get-docker.sh
sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
rm -f get-docker.sh
sudo usermod -aG docker $USER
