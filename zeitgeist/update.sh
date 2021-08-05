#!/bin/bash
sudo systemctl stop zeitgeist
wget https://github.com/zeitgeistpm/zeitgeist/releases/download/v0.1.2/zeitgeist -O $HOME/zeitgeist/target/release/zeitgeist
sudo systemctl start zeitgeist
