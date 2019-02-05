#!/bin/bash
# Author: Tancredi-Paul Grozav (paul@grozav.info)
# scans all ports of an IP

function isNumber(){
    [[ "$1" =~ ^[0-9]+$ ]] && return 0 || return 1
}

function is_up(){
    address=$1
    port=$2

    nc -w 1 -z $address $port
    if [ $? == 0 ]; then
	echo $address : $port is UP
    else
	echo $address : $port is DOWN
    fi
}

for((i=1; i<65535; i++)) do
	is_up $1 $i
done
