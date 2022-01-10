#!/bin/bash
sudo systemctl stop casper-node-launcher
CASPER_VERSION=1_4_4
TRUSTED_HASH=146fdc37964bd443731cd1cca107055370fdb3901698e7c76ee5b81faa25a5a7
if [ "$TRUSTED_HASH" != "null" ]; then sudo -u casper sed -i "/trusted_hash =/c\trusted_hash = '$TRUSTED_HASH'" /etc/casper/$CASPER_VERSION/config.toml; fi
sudo logrotate -f /etc/logrotate.d/casper-node
sudo systemctl start casper-node-launcher
