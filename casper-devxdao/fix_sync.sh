#!/bin/bash
sudo systemctl stop casper-node-launcher
TRUSTED_HASH=07c29ce2802589ee6509801e2bb6c903f9c88aab4209292e916772636bc4263b
if [ "$TRUSTED_HASH" != "null" ]; then sudo -u casper sed -i "/trusted_hash =/c\trusted_hash = '$TRUSTED_HASH'" /etc/casper/*/config.toml; fi
sudo logrotate -f /etc/logrotate.d/casper-node
sudo systemctl start casper-node-launcher
