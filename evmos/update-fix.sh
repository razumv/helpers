#!/bin/bash

sudo systemctl stop evmos
evmosd unsafe-reset-all

cd $HOME
rm -rf evmos

git clone https://github.com/tharsis/evmos.git
cd evmos
git checkout v0.4.2
make install

sed -i.bak -e  "s/^halt-height *=.*/halt-height = 0/" $HOME/.evmosd/config/app.toml

#cosmovisor

cp $HOME/go/bin/evmosd $HOME/.evmosd/cosmovisor/genesis/bin
mkdir -p $HOME/.evmosd/cosmovisor/upgrades/Olympus-Mons-v0.4.1/bin/
cp $HOME/go/bin/evmosd $HOME/.evmosd/cosmovisor/upgrades/Olympus-Mons-v0.4.1/bin/

peers="c893e2bf76b60099eecc20d4a9671ed9d4114464@65.21.193.112:26656,867f01d95299fff780c5a5139c2032bc6d773806@167.86.86.48:26656,72160278cbce6192d376816fd715705eb41bc56a@194.163.187.219:26656,bab8164b10a524b608330e787269a349f61a9dd4@135.181.58.43:26656,29558c38f6894066ebafa9f156f2839db9d454f6@23.88.0.168:26656"

sed -i.bak -e  "s/^persistent_peers *=.*/persistent_peers = \"$peers\"/" ~/.evmosd/config/config.toml

sudo systemctl restart evmos
