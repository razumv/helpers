#/bin/bash

function colors {
  GREEN="\e[32m"
  RED="\e[39m"
  NORMAL="\e[0m"
}

function logo {
  curl -s https://raw.githubusercontent.com/razumv/helpers/main/doubletop.sh | bash
}

function line {
  echo -e "${GREEN}-----------------------------------------------------------------------------${NORMAL}"
}


function replace_bootstraps {
	local config_path="$HOME/massa/massa-node/base_config/config.toml"
	local bootstrap_list=`wget -qO- https://raw.githubusercontent.com/SecorD0/Massa/main/bootstrap_list.txt | shuf -n50 | awk '{ print "        "$0"," }'`
	local len=`wc -l < "$config_path"`
	local start=`grep -n bootstrap_list "$config_path" | cut -d: -f1`
	local end=`grep -n "\[optionnal\] port on which to listen" "$config_path" | cut -d: -f1`
	local end=$((end-1))
	local first_part=`sed "${start},${len}d" "$config_path"`
	local second_part="
    bootstrap_list = [
${bootstrap_list}
    ]
"
	local third_part=`sed "1,${end}d" "$config_path"`
	echo "${first_part}${second_part}${third_part}" > "$config_path"
	sed -i -e "s%retry_delay *=.*%retry_delay = 10000%; " "$config_path"
  sudo systemctl restart massa
}
#Thanks to Let's Node!

line
logo
line
echo -e "Start replacing bootstrap list from community Let's Node"
replace_bootstraps
line
echo -e "${GREEN}DONE${NORMAL}"
