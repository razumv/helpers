#!/bin/bash
sudo systemctl stop casper-node-launcher
CASPER_VERSION=1_4_4
TRUSTED_HASH=0967714f6fc13c1baf71cf53785d654d78cf56ce8a506fc2a571c20082989e25
if [ "$TRUSTED_HASH" != "null" ]; then sudo -u casper sed -i "/trusted_hash =/c\trusted_hash = '$TRUSTED_HASH'" /etc/casper/$CASPER_VERSION/config.toml; fi
sudo logrotate -f /etc/logrotate.d/casper-node
sudo systemctl start casper-node-launcher
