#!/bin/bash

curl -s https://raw.githubusercontent.com/razumv/helpers/main/penumbra/functions.sh | bash
colors

line
logo
line
echo_start_update
line
echo "${GREEN} 1/2 Обновляем репозиторий ${NORMAL}"
source_git
line
echo "${GREEN} 2/2 Начинаем билд ${NORMAL}"
line
build_penumbra
line
echo_finish
