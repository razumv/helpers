#!/bin/bash

#add ufw rules
curl -s https://raw.githubusercontent.com/razumv/helpers/main/tools/install_ufw.sh | bash

sudo systemctl stop massa
rustup toolchain install nightly-2022-01-09
rustup default nightly-2022-01-09
#
cd $HOME
if [ ! -d $HOME/bk/ ]; then
	mkdir -p $HOME/bk
	cp $HOME/massa/massa-node/config/node_privkey.key $HOME/bk/
	cp $HOME/massa/massa-client/wallet.dat $HOME/bk/
fi
if [ ! -e $HOME/massa_bk.tar.gz ]; then
	tar cvzf massa_bk.tar.gz bk
fi

rm -rf $HOME/massa
git clone https://github.com/massalabs/massa.git
cd $HOME/massa
git checkout -- massa-node/config/config.toml
git checkout -- massa-node/config/peers.json
git fetch
git checkout TEST.8.0

cd $HOME/massa/massa-node/
cargo build --release
#sed -i 's%bootstrap_list *=.*%bootstrap_list = [ [ "62.171.166.224:31245", "8Cf1sQA9VYyUMcDpDRi2TBHQCuMEB7HgMHHdFcsa13m4g6Ee2h",], [ "149.202.86.103:31245", "5GcSNukkKePWpNSjx9STyoEZniJAN4U4EUzdsQyqhuP3WYf6nj",], [ "149.202.89.125:31245", "5wDwi2GYPniGLzpDfKjXJrmHV3p1rLRmm4bQ9TUWNVkpYmd4Zm",], [ "158.69.120.215:31245", "5QbsTjSoKzYc8uBbwPCap392CoMQfZ2jviyq492LZPpijctb9c",], [ "158.69.23.120:31245", "8139kbee951YJdwK99odM7e6V3eW7XShCfX5E2ovG3b9qxqqrq",],]%' "$HOME/massa/massa-node/base_config/config.toml"
sed -i "s/ip *=.*/ip = \"127\.0\.0\.1\"/" "$HOME/massa/massa-client/base_config/config.toml"
sed -i "s/^bind_private *=.*/bind_private = \"127\.0\.0\.1\:33034\"/" "$HOME/massa/massa-node/base_config/config.toml"
sed -i "s/^bind_public *=.*/bind_public = \"0\.0\.0\.0\:33035\"/" "$HOME/massa/massa-node/base_config/config.toml"
sed -i 's/.*routable_ip/# \0/' "$HOME/massa/massa-node/base_config/config.toml"
sed -i "/\[network\]/a routable_ip=\"$(curl -s ifconfig.me)\"" "$HOME/massa/massa-node/base_config/config.toml"
echo '[bootstrap]
max_ping = 10000
        bootstrap_list = [
        ["185.217.126.178:31245", "7bKVu43o1e6MZsj9xsKFcq14B75vNjirTSW2umaaTMngfbWsL3"],
        ["104.129.128.122:31245", "5EBePa834f8P3Ei6Vx7JFPzaq6JpsL4fDBRwePWfkiWM45yh6n"],
        ["65.21.242.5:31245",  "6gkR8BbtpKCSkSoXtdmj1722Gp1iH49D2F8kJhGD6k1VhJrChH"],
        ["51.250.18.248:31245",  "7tg9CfaM2xCiqyiZutpsagGrK5TtkU2paK7nLLoa21qdqjhZMR"],
        ["135.181.112.215:31245", "6jeAcQYVTjiJnw4eyr8SMWAsAaMtWLN6HutNfVvB9TfV8EZEep"],
        ["38.242.201.240:31245", "5yEwmraRY7wnEUZDzcWbnJ6sYqXaxcy8GfrDeJ6PTXx3HEKF92"],
        ["194.163.166.47:31245",   "74a6newcBkijYx6YSaQcyHX5j5oSjF2wFEAahGb7XNxQZSfboF"],
        ["194.163.182.239:31245", "6BDnKc5L7mpbW5K7c99TxZ5bQatpw2yiKPhTvPr49rNe9QnC7p"],
        ["178.170.41.160:31245", "8mVVr2pyNgDqxBS9LCCmX8gBLAvc1R6wt5mwZgbZtj26oGmUWs"],
        ["195.201.91.249:31245", "8UzkUgUTtdfntGsuUfbvmLZREnYYBU2mi6ggebcJsBsDTBX7z2"]
    ]' > massa/massa-node/config/config.toml
cp $HOME/bk/node_privkey.key $HOME/massa/massa-node/config/node_privkey.key

cd $HOME/massa/massa-client/
cargo build --release
cp $HOME/bk/wallet.dat $HOME/massa/massa-client/wallet.dat

sudo systemctl start massa
sleep 10
echo DONE
#massa_wallet_address=$(cargo run --release wallet_info | grep Address  |awk '{print $2}')
#cargo run --release -- buy_rolls $massa_wallet_address 1 0
#cargo run --release -- register_staking_keys $(cargo run --release wallet_info | grep Private | awk '{print $3}')
