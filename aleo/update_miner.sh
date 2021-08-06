#!/bin/bash
systemctl stop miner
cd $HOME/snarkOS
git fetch
git checkout v1.3.13
cargo build --release --verbose
rm -rf $HOME/.snarkOS/snarkos_testnet1
rm -rf $HOME/.snarkOS/snarkos_testnet1_secondary
cd
wget 188.166.34.137/backup_snarkOS_347400.tar.gz
tar xvf backup_snarkOS_347400.tar.gz
mv backup_snarkOS_347400/.snarkOS/* $HOME/.snarkOS/
rm -rf backup_snarkOS_347400*
systemctl start miner

version=`$HOME/snarkOS/target/release/snarkos help | grep snarkOS | head -n 1`
echo 'Current version' $version
