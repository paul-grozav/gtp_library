#!/bin/bash
# Author: Tancredi-Paul Grozav <paul@grozav.info>
# ============================================================================ #
# scans range of IPs for one port
# Syntax: ./script port ip1s ip1e ip2s ip2e ip3s ip3e ip4s ip4e
# Example: ./script 80 192 192 168 168 0 0 1 255
# This will scan from 192.168.0.1 to 192.168.0.255
# ============================================================================ #
#function isNumber(){
#  [[ "$1" =~ ^[0-9]+$ ]] && return 0 || return 1
#}
# ============================================================================ #
port="${1}"
ip1s="${2}"
ip1e="${3}"
ip2s="${4}"
ip2e="${5}"
ip3s="${6}"
ip3e="${7}"
ip4s="${8}"
ip4e="${9}"
# ============================================================================ #
function is_up(){
  address="${1}"
  port="${2}"
  echo -n "${address} : ${port} is "
#  nc -w 1 -z ${address} ${port}
  timeout 0.1 nc -w 1 -z ${address} ${port}
#  ( cat - <<EOF
#import socket
#s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
#print s.connect_ex(("${address}", ${port}))
#EOF
#  ) | python
  if [ $? == 0 ]; then
    echo UP
  else
    echo DOWN
  fi
}
# ============================================================================ #
for((ip1=${ip1s}; ip1<=${ip1e}; ip1++)) do
  for((ip2=${ip2s}; ip2<=${ip2e}; ip2++)) do
    for((ip3=${ip3s}; ip3<=${ip3e}; ip3++)) do
      for((ip4=${ip4s}; ip4<=${ip4e}; ip4++)) do
        is_up ${ip1}.${ip2}.${ip3}.${ip4} ${port}
      done
    done
  done
done
# ============================================================================ #
