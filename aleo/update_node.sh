#!/bin/bash
systemctl stop aleo
cd $HOME/snarkOS
git fetch
git checkout v1.3.13
#cargo build --release --verbose
wget https://github.com/AleoHQ/snarkOS/releases/download/v1.3.13/aleo-testnet1-v1.3.13-x86_64-unknown-linux-gnu.zip
unzip aleo-testnet1-v1.3.13-x86_64-unknown-linux-gnu.zip
mkdir -p $HOME/snarkOS/target/release/
mv snarkos $HOME/snarkOS/target/release/
rm -f aleo-testnet1-v1.3.13-x86_64-unknown-linux-gnu.zip
rm -rf $HOME/.snarkOS/snarkos_testnet1
rm -rf $HOME/.snarkOS/snarkos_testnet1_secondary
cd

#update snapshot
block=380000
wget 188.166.34.137/backup_snarkOS_$block.tar.gz
tar xvf backup_snarkOS_$block.tar.gz
mv backup_snarkOS_$block/.snarkOS/* $HOME/.snarkOS/
rm -rf backup_snarkOS_$block*

version=`$HOME/snarkOS/target/release/snarkos help | grep snarkOS | head -n 1`
echo 'Current version' $version
