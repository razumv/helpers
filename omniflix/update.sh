#!/bin/bash

cd $HOME/omniflixhub
git fetch --all
git checkout v0.2.2
make install
sudo systemctl restart omniflixhubd
