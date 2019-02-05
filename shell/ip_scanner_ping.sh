#!/bin/bash
# Author: Tancredi-Paul Grozav (paul@grozav.info)

function isNumber(){
    [[ "$1" =~ ^[0-9]+$ ]] && return 0 || return 1
}

function is_up(){
	address=$1
#	port=$2

#	nc -z $address $port # Try to connect on a given port
	ping -c 1 $address > /dev/null 2>&1
	if [ $? == 0 ]; then
		echo $address - is UP - hostname $(host $address | grep -v "not found" | awk '{print $NF}') - openPorts $(nmap -Pn $address | grep "open" | awk -F'/' '{printf $1" "}')
	else
		echo $address - is DOWN - hostname $(host $address | grep -v "not found" | awk '{print $NF}')
	fi
}

for((i=$1; i<=$2; i++)) do
    for((j=$3; j<=$4; j++)) do
        address="192.168.$i.$j"
        is_up $address # $5
    done
done
