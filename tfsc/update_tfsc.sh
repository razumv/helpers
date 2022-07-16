#!/bin/bash

pkill -9 tfsc

cd $HOME/tfsc/
wget -O $HOME/tfsc/tfsc https://fastcdn.uscloudmedia.com/transformers/test/ttfSC_0.1.0 _2f1a297_devnet
chmod +x $HOME/tfsc/tfsc

tmux new-session -d -s tfsc 'cd $HOME/tfsc/ && $HOME/tfsc/tfsc -m'
