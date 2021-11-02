#!/bin/bash
echo "-----------------------------------------------------------------------------"
curl -s https://raw.githubusercontent.com/razumv/helpers/main/doubletop.sh | bash
echo "-----------------------------------------------------------------------------"
echo "Устанавливаем софт"
echo "-----------------------------------------------------------------------------"
curl -s https://raw.githubusercontent.com/razumv/helpers/main/tools/install_node14.sh | bash &>/dev/null
sudo apt install python3-pip -y
pip install virtualenv

useradd -m user -s /bin/bash
sudo su user

virtualenv $HOME/forta
source $HOME/forta/bin/activate
cd $HOME/forta
mkdir my-agent
cd my-agent
#npx forta-agent@latest init --typescript
