#!/bin/bash

#add ufw rules
curl -s https://raw.githubusercontent.com/razumv/helpers/main/tools/install_ufw.sh | bash

sudo systemctl stop zeitgeist
wget https://github.com/zeitgeistpm/zeitgeist/releases/download/v0.1.2/zeitgeist -O $HOME/zeitgeist/target/release/zeitgeist
sudo systemctl start zeitgeist
