#!/bin/bash
cd $HOME
source $HOME/.profile
celestia-appd keys add $CELESTIA_NODENAME &> $HOME/celestia_account.txt
CELESTIA_ADDR=$(celestia-appd keys show $CELESTIA_NODENAME -a)
echo 'export CELESTIA_ADDR='${CELESTIA_ADDR} >> $HOME/.profile
CELESTIA_VALOPER=$(celestia-appd keys show $CELESTIA_NODENAME --bech val -a)
echo 'export CELESTIA_VALOPER='${CELESTIA_VALOPER} >> $HOME/.profile
source $HOME/.profile
