#!/bin/bash
sudo systemctl stop casper-node-launcher
CASPER_VERSION=1_4_2
# KNOWN_ADDRESSES=$(sudo -u casper cat /etc/casper/$CASPER_VERSION/config.toml | grep known_addresses)
# KNOWN_VALIDATOR_IPS=$(grep -oE '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' <<< "$KNOWN_ADDRESSES")
# IFS=' ' read -r KNOWN_VALIDATOR_IP _REST <<< "$KNOWN_VALIDATOR_IPS"
# TRUSTED_HASH=$(curl -s $KNOWN_VALIDATOR_IP:8888/status | jq -r .last_added_block_info.hash | tr -d '\n')
TRUSTED_HASH=$(casper-client get-block --node-address http://3.208.91.63:7777 -b 319800 | jq -r .result.block.hash)
if [ "$TRUSTED_HASH" != "null" ]; then sudo -u casper sed -i "/trusted_hash =/c\trusted_hash = '$TRUSTED_HASH'" /etc/casper/$CASPER_VERSION/config.toml; fi
sudo logrotate -f /etc/logrotate.d/casper-node
sudo systemctl start casper-node-launcher
