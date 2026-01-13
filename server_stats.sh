#!/bin/bash

set -euo pipefail

CPU_A=$(grep 'cpu ' /proc/stat)
IDLE_A=$(echo $CPU_A | awk '{ print $5 }')
TOTAL_A=$(echo $CPU_A | awk '{for(i=2;i<=NF;i++) sum+=$i; print sum}')
sleep 1
CPU_B=$(grep 'cpu ' /proc/stat)
IDLE_B=$(echo $CPU_B | awk '{ print $5 }')
TOTAL_B=$(echo $CPU_B| awk '{for(i=2;i<=NF;i++) sum+=$i; print sum}')
DIFF_IDLE=$(($IDLE_B - $IDLE_A))
DIFF_TOTAL=$(($TOTAL_B - $TOTAL_A))
if (( DIFF_TOTAL == 0 )); then
  CPU_USAGE="0.00"
else
  CPU_USAGE=$(awk "BEGIN { printf \"%.2f\", 100 * ($DIFF_TOTAL - $DIFF_IDLE) / $DIFF_TOTAL }")
fi

MEM_USAGE=$(free -m | awk '
/Mem:/ {
  used = $2 - $7
  printf "%.2f", used / $2 * 100
}')

#MEM=$(free -m | grep Mem:)
#USED_MEM=$(echo $MEM | awk '{ print $3}')
#TOTAL_MEM=$(echo $MEM | awk '{ print $2}')
#MEM_USAGE=$(((100 * USED_MEM) / TOTAL_MEM))


DISK_USAGE=$(df -BG / | awk 'NR==2 {print $5}')


echo "Gathering server information..."
echo "-----------------------------------"
echo "Uptime Information"
uptime
echo "-----------------------------------"
hostnamectl | grep -E 'Operating System|Kernel'
echo "-----------------------------------"
echo "CPU Information:"
echo "${CPU_USAGE}% CPU Usage"
echo "-----------------------------------"
echo "Memory Information:"
echo "${MEM_USAGE}% RAM Usage"
echo "-----------------------------------"
echo "Disk Information:"
echo "${DISK_USAGE} Disk Usage"
echo "-----------------------------------"
echo "Top 5 process by CPU usage"
ps -eo pid,ppid,cmd,%cpu --sort=-%cpu | head -n 6
echo "-----------------------------------"
echo "Top 5 process by memory usage"
ps -eo pid,ppid,cmd,%mem --sort=-%mem | head -n 6
echo "-----------------------------------"
