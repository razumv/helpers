#!/bin/bash
version=`omniflixhubd version`
if [[ $version != "0.2.2" ]]; then
  cd $HOME/omniflixhub
  git fetch --all
  git checkout v0.2.2
  make install
  sudo systemctl restart omniflixhubd
fi
