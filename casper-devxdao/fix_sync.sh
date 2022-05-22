#!/bin/bash
sudo systemctl stop casper-node-launcher
TRUSTED_HASH=66f65b24a74b8fab0eb520fa2fc076139944838be7c2b0df9f080fba0c601181
if [ "$TRUSTED_HASH" != "null" ]; then sudo -u casper sed -i "/trusted_hash =/c\trusted_hash = '$TRUSTED_HASH'" /etc/casper/*/config.toml; fi
sudo logrotate -f /etc/logrotate.d/casper-node
sudo systemctl start casper-node-launcher
