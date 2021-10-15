#!/bin/bash
#Thank's for https://raw.githubusercontent.com/bobu4/massa/main/bal.sh

if [ ! -e $HOME/massa/massa-client/massa-client ]; then
	wget https://raw.githubusercontent.com/razumv/helpers/main/massa/massa-client -O $HOME/massa/massa-client/massa-client
  chmod +x $HOME/massa/massa-client/massa-client
fi

cd $HOME/massa/massa-client
massa_wallet_address=$(./massa-client --cli true wallet_info | jq -r '.balances | keys[0]')
while true
do
	balance=$(./massa-client --cli true wallet_info | jq -r '.balances[].final_ledger_data.balance')
	int_balance=${balance%%.*}
	if [ $int_balance -gt "99" ]; then
		echo "More than 99"
		resp=$(./massa-client buy_rolls $massa_wallet_address $(($int_balance/100)) 0)
		echo $resp
	elif [ $int_balance -lt "100" ]; then
		echo "Less than 100"
	fi
	printf "sleep"
	for((sec=0; sec<60; sec++))
	do
		printf "."
		sleep 1
	done
	printf "\n"
done
