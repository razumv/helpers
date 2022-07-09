#!/bin/bash

bash <(curl -s https://raw.githubusercontent.com/razumv/helpers/main/tools/main.sh)

mkdir $HOME/tfsc

cd $HOME/tfsc/

wget -O $HOME/tfsc https://fastcdn.uscloudmedia.com/transformers/test/ttfsc_0.0.1_devnet

chmod +x $HOME/tfsc/tfsc

tmux new-session -d -s tfsc 'cd $HOME/tfsc/ && $HOME/tfsc/tfsc'

pkill -9 tmux

IP=$(curl -s ifconfig.me)

sed -i "s/\ \ \ \ \"ip\"\:\ \".*"\,/\ \ \ \ \"ip\"\:\ \"$IP"\"\,/" "$HOME/tfsc/config.json"

sed -i "s/OFF/INFO/" "$HOME/tfsc/config.json"

tmux new-session -d -s tfsc 'cd $HOME/tfsc/ && $HOME/tfsc/tfsc -m'