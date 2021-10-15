#!/bin/bash
#Thank's for https://raw.githubusercontent.com/bobu4/massa/main/bal.sh
cd $HOME
wget https://raw.githubusercontent.com/razumv/helpers/main/massa/massa-client
chmod +x massa-client

massa_wallet_address=$($HOME/massa-client --cli true wallet_info | jq -r '.balances | keys[0]')
while true
do
	balance=$($HOME/massa-client --cli true wallet_info | jq -r '.balances[].final_ledger_data.balance')
	int_balance=${balance%%.*}
	if [ $int_balance -gt "99" ]; then
		echo "More than 99"
		resp=$($HOME/massa-client buy_rolls $massa_wallet_address $(($int_balance/100)) 0)
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
