#!/bin/bash
echo "-----------------------------------------------------------------------------"
curl -s https://raw.githubusercontent.com/razumv/helpers/main/doubletop.sh | bash
echo "-----------------------------------------------------------------------------"
cd $HOME/evmos
git fetch --all && git checkout v0.1.3
make install
sudo systemctl restart evmos
