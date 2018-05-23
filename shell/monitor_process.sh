#!/bin/bash
# Author: Tancredi-Paul Grozav <paul@grozav.info>
# ============================================================================ #
executable_full_path="$1" &&

echo -n "PID: " &&
pid="$(pidof $executable_full_path)" &&
echo $pid &&

echo -n "CPU: " &&
top -p $pid -d 0.5 -b -n 1 | awk -v pid=$pid '{if($1==pid){print $9}}' &&

echo -n "Resident Memory(B): " &&
echo $((1000 * $(ps -p $pid -o rss | tail -n1))) &&

echo -n "Virtual Memory(B): " &&
echo $((1024 * $(ps -p $pid -o vsz | tail -n1))) &&

echo -n "Number of threads: " &&
ls -l /proc/$pid/task/ | grep ^d | wc -l &&

echo -n "Number of file descriptors: " &&
ls -l /proc/$pid/fd | grep ^l | wc -l &&

echo -n "Process status: " &&
ps -p $pid -o stat | tail -n1 &&

echo -n "Process owner user: " &&
echo $(ps -p $pid -o euser | tail -n1)"("$(ps -p $pid -o euid | tail -n1)")" &&

echo -n "Process start time: " &&
date --date "$(ps -p $pid -o lstart | tail -n1)" +"%Y-%m-%d %H:%M:%S" &&

echo -n "Process current working directory: " &&
readlink -f /proc/$pid/cwd &&

echo -n "Process start command: " &&
cat /proc/$pid/cmdline && echo &&

echo &&
echo "Open connections: " &&
lsof -i -a -p $pid | awk '{if(NR>1){print $4" "$5" "$8" "$9" "$10}}' &&

echo &&
echo "Open files: " &&
ls -lv /proc/$pid/fd | grep -v socket | awk '{if(NR>1){print $9" "$11}}' &&

echo
# ============================================================================ #