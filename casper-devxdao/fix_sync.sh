#!/bin/bash
sudo systemctl stop casper-node-launcher
TRUSTED_HASH=62d08ce1f5815ea07632f5396f0408f49ac3deb60d022e1b6ee560e156e8655d
if [ "$TRUSTED_HASH" != "null" ]; then sudo -u casper sed -i "/trusted_hash =/c\trusted_hash = '$TRUSTED_HASH'" /etc/casper/*/config.toml; fi
sudo logrotate -f /etc/logrotate.d/casper-node
sudo systemctl start casper-node-launcher
