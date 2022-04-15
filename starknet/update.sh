#!/bin/bash

cd ~/pathfinder/py
python3 -m venv .venv
source .venv/bin/activate
PIP_REQUIRE_VIRTUALENV=true pip install --upgrade pip
PIP_REQUIRE_VIRTUALENV=true pip install -r requirements-dev.txt
cargo build --release --bin pathfinder

source $HOME/.bash_profile
systemctl restart starknet
