#!/bin/bash

curl -s https://raw.githubusercontent.com/razumv/helpers/main/penumbra/functions.sh | bash
colors

line
logo
line
echo_start_install
line
echo "${GREEN}1/5 Устанавливаем софт ${NORMAL}"
line
install_tools
line
echo "${GREEN}2/5 Клонируем репозиторий ${NORMAL}"
line
source_git
line
echo "${GREEN}3/5 Начинаем билд ${NORMAL}"
line
build_penumbra
line
echo "${GREEN}4/5 Создаем кошелек ${NORMAL}"
line
generate_wallet
line
echo "${GREEN}5/5 Кошелек успешно создан, следуйте по гайду дальше ${NORMAL}"
line
echo_finish
