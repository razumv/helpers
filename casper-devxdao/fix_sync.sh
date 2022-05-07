#!/bin/bash
sudo systemctl stop casper-node-launcher
TRUSTED_HASH=8dcde9e4ee841a617d90e8f29c48a1e3c0cd36e5ef227ceaec0fda329b7d4846
if [ "$TRUSTED_HASH" != "null" ]; then sudo -u casper sed -i "/trusted_hash =/c\trusted_hash = '$TRUSTED_HASH'" /etc/casper/*/config.toml; fi
sudo logrotate -f /etc/logrotate.d/casper-node
sudo systemctl start casper-node-launcher
