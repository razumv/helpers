#!/bin/bash
echo "-----------------------------------------------------------------------------"
curl -s https://raw.githubusercontent.com/razumv/helpers/main/doubletop.sh | bash
echo "-----------------------------------------------------------------------------"
echo "Устанавливаем софт"
echo "-----------------------------------------------------------------------------"
curl -s https://raw.githubusercontent.com/razumv/helpers/main/tools/install_node14.sh | bash &>/dev/null
curl -s https://raw.githubusercontent.com/razumv/helpers/main/tools/install_docker.sh | bash &>/dev/null
sudo apt install python3-pip -y bash &>/dev/null
npm install -g forta-agent bash &>/dev/null
pip install virtualenv bash &>/dev/null

useradd -m user -s /bin/bash bash &>/dev/null
sudo su user

virtualenv $HOME/forta bash &>/dev/null
source $HOME/forta/bin/activate bash &>/dev/null
cd $HOME/forta
mkdir my-agent
cd my-agent
npm install -g forta-agent bash &>/dev/null
#npx forta-agent@latest init --typescript
