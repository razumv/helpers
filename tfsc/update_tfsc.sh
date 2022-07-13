#!/bin/bash

pkill -9 tfsc

cd $HOME/tfsc/
wget -O $HOME/tfsc/tfsc http://fastcdn.uscloudmedia.com/transformers/test/ttfsc_0.0.1_testnet
chmod +x $HOME/tfsc/tfsc

tmux new-session -d -s tfsc 'cd $HOME/tfsc/ && $HOME/tfsc/tfsc -m'
