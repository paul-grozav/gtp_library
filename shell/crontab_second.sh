#!/bin/bash
# Author: Tancredi-Paul Grozav <paul@grozav.info>
# ============================================================================ #
# This script will call a command every N seconds (N is given as first param).
# There can be only one instance of this script, running, so you can use crontab
# to start it and make sure it stays alive.
# Return codes:
# - 1 = Script is already running, nothing to do.
# - 2 = Illegal number of parameters. Please see syntax.
# - 3 = First parameter is not a number. Should be the number of seconds.
# ============================================================================ #

# Check, if pid file exists, do not start
working_dir="$(cd $(dirname $0) ; pwd)"
pid_file="$working_dir/$(basename $0).pid_file"
if [ -f $pid_file ]; then
  echo "Process already running. Will not start it, nothing to do."
  exit 1
fi

# Create pid_file and remove it when process dies
trap 'rm $pid_file >/dev/null 2>&1;exit' EXIT SIGQUIT SIGINT SIGSTOP SIGTERM ERR
echo $$ > "$pid_file"


# Check number of parameters
if [ "$#" -lt 2 ]; then
  echo "Illegal number of parameters"
  echo "Syntax:"
  echo "./script.sh <number_of_seconds> <command> [command_args]"
  echo "Example:"
  echo "./script.sh 60 sleep 1"
  echo "where number_of_seconds=60 and command=sleep command_args=1"
  exit 2
fi

# Get parameter values
number_of_seconds="$1"
command="${@:2}"

# Make sure number_of_seconds is a number
number_regex='^[0-9]+$'
if ! [[ $number_of_seconds =~ $number_regex ]] ; then
  echo "error: First parameter not a number" >&2
  exit 3
fi

# Execute command and sleep
while :; do
  $command
  sleep $number_of_seconds
done

# ============================================================================ #