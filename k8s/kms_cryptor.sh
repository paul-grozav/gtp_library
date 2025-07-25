#!/bin/bash
# ============================================================================ #
# Authors:
# - Tancredi-Paul Grozav <paul@grozav.info>
# ============================================================================ #
# Encrypts data with a key that is stored locally, but the key is also encrypted
# using AWS' KMS.
# ============================================================================ #
# Usage example:
# kkid="b2c9abe4-3bd2-4df1-b6c8-7e91f2a04ca7" &&
# lkf="$(pwd)/one.key" &&
#
# Encrypt and decrypt a message:
# cryptor="bash kms_cryptor.sh --kms_key_id ${kkid} --local_key ${lkf}" &&
# echo SECRET | ${cryptor} --encrypt | ${cryptor} --decrypt
#
# Encrypt to and decrypt from a file:
# echo MY_DIRTY_SECRET | ${cryptor} --encrypt > secret.enc
# ${cryptor} --decrypt < secret.enc
# ============================================================================ #
should_debug=1 &&
# Uncomment to disable debugging
should_debug=0 &&
# Start debugging
( [ ${should_debug} -eq 1 ] && set -x || true )  &&
# ============================================================================ #





# ============================================================================ #
# Generate a new key locally
# ============================================================================ #
function generate_key()
{(
  set -euo pipefail

  # 1. Generate 32-byte random key in memory
  echo "Generating new random key ..." &&
  raw_key="$( openssl rand 32 )" &&

  # 2. Encrypt the key using AWS KMS (read from fd 3) returned as base64 encoded
  echo "Encrypting the new key with KMS ..." &&
  encrypted_key=$( aws kms encrypt \
    --key-id "${params[kms_key_id]}" \
    --plaintext fileb:///dev/fd/3 \
    --output text \
    --query CiphertextBlob 3<<<"${raw_key}" ) &&

  # 3. B64Decode and save raw encrypted key to local file
  echo "Saving the encrypted new key ..." &&
  echo "${encrypted_key}" | base64 --decode > "${params[local_key]}" &&

  # 4. Cleanup key from memory
  unset raw_key &&

  true
)} &&
# ============================================================================ #





# ============================================================================ #
# Encrypt stdin with local key. Key which is encrypted with KMS key.
# ============================================================================ #
function encrypt()
{(
  set -euo pipefail

  # 1. Decrypt local key with KMS
  raw_key="$( aws kms decrypt \
    --ciphertext-blob fileb://${params[local_key]} \
    --output text \
    --query Plaintext | base64 --decode)" &&

  # 2. Encrypt stdin with raw_key, then print to stdout
  openssl enc -aes-256-cbc -pbkdf2 -salt \
  -pass fd:3 3<<<"${raw_key}" \
  -out /dev/stdout &&

  # 3. Cleanup key from memory
  unset raw_key &&

  true
)} &&
# ============================================================================ #





# ============================================================================ #
# Decrypt stdin with local key. Key which is encrypted with KMS key.
# ============================================================================ #
function decrypt()
{(
  set -euo pipefail

  # 1. Decrypt local key with KMS
  raw_key="$( aws kms decrypt \
    --ciphertext-blob fileb://${params[local_key]} \
    --output text \
    --query Plaintext | base64 --decode)" &&

  # 2. Decrypt stdin with raw_key, then print to stdout
  openssl enc -d -aes-256-cbc -pbkdf2 -salt \
  -pass fd:3 3<<<"${raw_key}" \
  -in /dev/stdin &&

  # 3. Cleanup key from memory
  unset raw_key &&

  true
)} &&
# ============================================================================ #





# ============================================================================ #
# Print help
# ============================================================================ #
function print_help()
{
  echo "Usage: ${0} --kms_key_id KEY_ID --local_key path/to.key COMMAND

The COMMAND can be one of the following:
  --generate_key   Generate a new key, encypt it with KMS and save it locally.
  --encrypt        Encrypt stdin with local key
  --decrypt        Decrypt stdin with local key
  --help           Print the help message.
" &&
  true
} &&
# ============================================================================ #





# ============================================================================ #
# Main function
# ============================================================================ #
# Initialize variables to store key-value pairs
declare -A params &&

# Parse arguments - don't shift last param, which is COMMAND
while [[ ${#} -gt 1 ]]
do
  if [[ ${1} == --* ]]
  then
    # Remove leading '--' from key
    key="${1#--}" &&
    # Check if next argument exists and is not another key
    if [[ ${#} -gt 1 && ${2} != --* ]]
    then
      params["${key}"]="${2}" &&
      # Move past key and value
      shift 2
    else
      echo "Warning: Missing value for ${1}"
      # exit 1
      shift
    fi
  else
    echo "Warning: Invalid argument ${1}" &&
    exit 1
  fi
done &&

# If no parameter
if [ ${#} == 0 ]
then
  print_help
fi &&

# Case logic
first_param="${1}" &&
shift &&
exit_code=0 &&
if [ ${first_param} ]
then
  case "${first_param}" in
    --generate_key) ${first_param#--} ${@} ; exit_code=${?} ;;
    --encrypt) ${first_param#--} ${@} ; exit_code=${?} ;;
    --decrypt) ${first_param#--} ${@} ; exit_code=${?} ;;
    *) print_help ${@} ; exit_code=${?} ;;
    esac
fi &&

# Stop debugging
( [ ${should_debug} -eq 1 ] && set +x || true ) &&

exit ${exit_code}
# ============================================================================ #
