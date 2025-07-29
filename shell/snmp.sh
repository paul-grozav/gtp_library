# ============================================================================ #
# Author: Tancredi-Paul Grozav <paul@grozav.info>
# ============================================================================ #

# Specify just the protocol version, community string and IP of device
snmpwalk -v 2c -c my-public 192.168.0.1


# stdbuf -i0 -o0 -e0 COMMAND1 | CMD2 - ensures it will pass output to CMD2 as
# soon as it is flushed by COMMAND1, otherwise, by default, the pipe will buffer
# the data.
# snmpwalk parameters:
# -Cc - avoids errors like "Error: OID not increasing:"
# -On - Prints the OID numeric values instead of the field names 
stdbuf -i0 -o0 -e0 \
  snmpwalk -v 2c -c my-public -On -Cc 192.168.0.1 | tee 192.168.0.1.log


# Print both OID and field names. 
snmpwalk -v2c -c my-public -On 192.168.0.1 | while IFS=' = ' read -r oid value
do
  # snmpwalk only prints OID but using snmptranslate we obtain the field name
  name=$(snmptranslate "${oid}")
  echo "${name} (${oid}) = ${value}"
done

# ============================================================================ #
