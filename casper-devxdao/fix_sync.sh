#!/bin/bash
sudo systemctl stop casper-node-launcher
CASPER_VERSION=1_4_3
TRUSTED_HASH=6630fedc91BA7BCF94228659beA93c1B0F616F477A6dd67265A296Cf54adfEfb
if [ "$TRUSTED_HASH" != "null" ]; then sudo -u casper sed -i "/trusted_hash =/c\trusted_hash = '$TRUSTED_HASH'" /etc/casper/$CASPER_VERSION/config.toml; fi
sudo logrotate -f /etc/logrotate.d/casper-node
sudo systemctl start casper-node-launcher
