#!/bin/bash
#rm -rf $HOME/Bit-Country-Blockchain &>/dev/null
#rm -rf $HOME/.local/share/bitcountry-node/chains/tewai_testnet/db/ &>/dev/null

echo "-----------------------------------------------------------------------------"
curl -s https://raw.githubusercontent.com/razumv/helpers/main/doubletop.sh | bash
echo "-----------------------------------------------------------------------------"
echo "Устанавливаем софт"
echo "-----------------------------------------------------------------------------"
curl -s https://raw.githubusercontent.com/razumv/helpers/main/tools/install_ufw.sh | bash &>/dev/null
curl -s https://raw.githubusercontent.com/razumv/helpers/main/tools/install_rust.sh | bash &>/dev/null
sudo apt install --fix-broken -y &>/dev/null
sudo apt install nano mc -y &>/dev/null
source $HOME/.profile &>/dev/null
source $HOME/.bashrc &>/dev/null
source $HOME/.cargo/env &>/dev/null
sleep 1
echo "Весь необходимый софт установлен"
echo "-----------------------------------------------------------------------------"
mkdir -p $HOME/bitcountry_bk/
cp $HOME/.local/share/metaverse-node/chains/tewai_testnet/network/secret_ed25519 $HOME/bitcountry_bk/
cp $HOME/.local/share/bitcountry-node/chains/tewai_testnet/network/secret_ed25519 $HOME/bitcountry_bk/

if [ ! -d $HOME/Metaverse-Network/ ]; then
  git clone https://github.com/bit-country/Metaverse-Network.git &>/dev/null
fi
cd $HOME/Metaverse-Network
git fetch
git stash
git checkout release-0.0.3 &>/dev/null
echo "Репозиторий успешно склонирован, начинаем билд"
echo "-----------------------------------------------------------------------------"

make init &>/dev/null
cargo build --release --features=with-tewai-runtime &>/dev/null
echo "Билд завершен успешно"
echo "-----------------------------------------------------------------------------"

sudo systemctl restart bitcountry

echo "Нода обновилена и запущена"
echo "-----------------------------------------------------------------------------"
