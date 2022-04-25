#!/bin/bash
sudo systemctl stop casper-node-launcher
TRUSTED_HASH=32c874bc3a383b5a3e2daad19598202abd60170028b540e022a7f32067a2f446
if [ "$TRUSTED_HASH" != "null" ]; then sudo -u casper sed -i "/trusted_hash =/c\trusted_hash = '$TRUSTED_HASH'" /etc/casper/*/config.toml; fi
sudo logrotate -f /etc/logrotate.d/casper-node
sudo systemctl start casper-node-launcher
