#!/bin/bash
sudo systemctl stop casper-node-launcher
TRUSTED_HASH=6ed87e9859b0db58a59a4a989fb931d8e054d7535874a82c0ae199523f3ce6c5
if [ "$TRUSTED_HASH" != "null" ]; then sudo -u casper sed -i "/trusted_hash =/c\trusted_hash = '$TRUSTED_HASH'" /etc/casper/*/config.toml; fi
sudo logrotate -f /etc/logrotate.d/casper-node
sudo systemctl start casper-node-launcher
