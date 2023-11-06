#! /usr/bin/env bash

RED='\033[0;31m'
GREEN='\033[0;32m'
RESET='\033[0m'

function banner(){
	HOSTNAME=$(hotsname)
	UPTIME=$(uptime)
}

function cdisk(){
	echo "########### Start Disk Usage Checking ###########"
	CMD=$(df -hT)
	CMDB=$(tail -n +2 <<< "${CMD}")
	awk '{
		threshold = 80
		#threshold = 10
		device = $1
		sub("%","",$6)
		percentage = $6
		if(device ~ "/dev/" && percentage >= threshold){
			exit 1
		}
	}' <<< "${CMDB}"
	if [[ $? -eq 1 ]];then
		echo -e "${RED}Disk usage reach to threshold. Command \`df\` information below.${RESET}"
		echo "${CMD}"
	else
		echo -e "           ${GREEN}Disk Check PASSING${RESET}"
	fi
	echo -e "########### End Disk Usage Checking ###########\n"
}

function cram() {
	echo "########### Start RAM Usage Checking ###########"
	CMD=$(free)
	CMDB=$(tail -n +2 <<< "${CMD}")
	awk '{
		threshold = 80
		#threshold = 10
		total = $2
		used = $3
		percentage = used / total * 100
		if(percentage >= threshold){
			exit 1
		}
	}' <<< "${CMDB}"
	if [[ $? -eq 1 ]];then
		echo -e "${RED}RAM reach to threshold. Commnad \`free\` information below.${RESET}"
		echo "${CMD}"
	else
		echo -e "           ${GREEN}RAM Check PASSING${RESET}"
	fi
	echo -e "########### End RAM Usage Checking ###########\n"
}

function ccpu(){
	echo "########### Start CPU Usage Checking ###########"
	CMD=$(top -b -n 1 -o %CPU)
	IDLE=$((grep '%Cpu(s)' <<< "${CMD}") | cut -d "," -f 4 | cut -d " " -f 2)
	CMDB=$((grep '%CPU' <<< "${CMD}") && ((tail -n +8 | head -10) <<< "${CMD}"))
	awk '{
		idle = $0
		threshold = 20
		#threshold = 100
		if(idle <= threshold){
			exit 1
		}
	}' <<< "${IDLE}"
	if [[ $? -eq 1 ]];then
		echo -e "${RED}CPU reach to threshold. List CPU usage top 10 processes below.${RESET}"
		echo "${CMDB}"
	else
		echo -e "           ${GREEN}CPU Check PASSING${RESET}"
	fi
	echo -e "########### End CPU Usage Checking ###########\n"
}

function main(){
	cdisk
	cram
	ccpu
}
main
