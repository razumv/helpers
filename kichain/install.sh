#!/bin/bash
if [ ! $KICHAIN_NODENAME ]; then
	read -p "Enter node name: " KICHAIN_NODENAME
fi
echo 'Your node name: ' $KICHAIN_NODENAME
sleep 1
echo 'export KICHAIN_NODENAME='$KICHAIN_NODENAME >> $HOME/.profile


sudo apt update
sudo apt install mc jq curl build-essential git wget -y
curl https://dl.google.com/go/go1.16.5.linux-amd64.tar.gz | sudo tar -C /usr/local -zxvf -

cat <<'EOF' >>$HOME/.profile
export GOROOT=/usr/local/go
export GOPATH=$HOME/go
export GO111MODULE=on
export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin
EOF

source $HOME/.profile
sleep 1

git clone https://github.com/KiFoundation/ki-tools.git
cd ki-tools
git checkout testnet
make install

mkdir testnet
export NODE_ROOT=$HOME/testnet
mkdir -p $NODE_ROOT/kid $NODE_ROOT/kicli $NODE_ROOT/kilogs
cd $NODE_ROOT

kid init $KICHAIN_NODENAME --chain-id kichain-t-2 --home ./kid/
#kicli keys add $KICHAIN_NODENAME --home ./kicli/ &>> $NODE_ROOT/account.txt
#kid add-genesis-account $(kicli keys show $KICHAIN_NODENAME -a --home kicli/ ) 100000000utki --home kid/
#kid gentx \
#	--commission-max-change-rate=0.1 \
#	--commission-max-rate=0.1 \
#	--commission-rate=0.1 \
#	--min-self-delegation=1 \
#	--amount=100000000utki \
#	--pubkey `kid tendermint show-validator --home ./kid/` \
#	--name=$KICHAIN_NODENAME \
#	--home ./kid/ \
#	--home-client ./kicli/
