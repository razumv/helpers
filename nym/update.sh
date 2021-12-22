#!/bin/bash
echo "-----------------------------------------------------------------------------"
curl -s https://raw.githubusercontent.com/razumv/helpers/main/doubletop.sh | bash
echo "-----------------------------------------------------------------------------"

sudo systemctl stop nym

rustup default stable &>/dev/null
rustup update &>/dev/null

mkdir -p $HOME/nym_bk/milhon $HOME/nym_bk/sandbox

export NODENAME=`ls ~/.nym/mixnodes/`
mv $HOME/.nym/mixnodes/* $HOME/nym_bk/milhon/
cd $HOME/nym
git fetch &>/dev/null
git checkout v0.12.0 &>/dev/null
cargo build --release
$HOME/nym/target/release/nym-mixnode init --id $NODENAME --host $(curl -s ifconfig.me) --wallet-address $wallet_addr > $HOME/nym12.txt
cp -r $HOME/.nym/mixnodes/* $HOME/nym_bk/sandbox

sudo systemctl restart nym
identity_key=`cat $HOME/nym12.txt | awk '/Identity Key:/ {print $3}'`
sphinx_key=`cat $HOME/nym12.txt | awk '/Sphinx Key:/ {print $3}'`
owner_signature=`cat $HOME/nym12.txt | awk '/Owner Signature:/ {print $3}'`
host=`curl -s ifconfig.me`
version=`cat $HOME/nym12.txt | awk '/Version:/ {print $2}'`

echo "-----------------------------------------------------------------------------"
curl "Нода NYM успешно обновлена до версии v0.12.0"
echo "-----------------------------------------------------------------------------"
curl "Информация для бонда ноды в новом кошельке:"
echo "Identity key:" $identity_key
echo "Sphinx Key:" $sphinx_key
echo "Owner Signature:" $owner_signature
echo "Host:" $host
echo "Version:" $version
echo "-----------------------------------------------------------------------------"
