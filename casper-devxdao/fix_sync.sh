#!/bin/bash
sudo systemctl stop casper-node-launcher
TRUSTED_HASH=134e37f7b9c21341bf20d57fa62e164aa3ae1325eea7e1a08c5184a2bdd5adcd
if [ "$TRUSTED_HASH" != "null" ]; then sudo -u casper sed -i "/trusted_hash =/c\trusted_hash = '$TRUSTED_HASH'" /etc/casper/*/config.toml; fi
sudo logrotate -f /etc/logrotate.d/casper-node
sudo systemctl start casper-node-launcher
