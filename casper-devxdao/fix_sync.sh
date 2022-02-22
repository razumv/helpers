#!/bin/bash
sudo systemctl stop casper-node-launcher
CASPER_VERSION=1_4_4
TRUSTED_HASH=793aa8a32614dea1bfd123de2fde0b06cd0b5ac15b60fffdaf783a0b77086139
if [ "$TRUSTED_HASH" != "null" ]; then sudo -u casper sed -i "/trusted_hash =/c\trusted_hash = '$TRUSTED_HASH'" /etc/casper/$CASPER_VERSION/config.toml; fi
sudo logrotate -f /etc/logrotate.d/casper-node
sudo systemctl start casper-node-launcher
