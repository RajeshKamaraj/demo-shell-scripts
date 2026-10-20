#!/bin/bash

# EC2 VM Health Check Script
# Healthy if CPU, Memory, and Disk usage are all below 60%.
# Unhealthy if any of the three usage values exceed 60%.

THRESHOLD=60

# Get CPU utilization in %
# "vmstat" returns idle percentage; subtract from 100 to get used percentage.
cpu_idle=$(vmstat 1 2 | tail -1 | awk '{print $15}')
cpu_usage=$(echo "100 - $cpu_idle" | bc)

# Get memory utilization in %
mem_total=$(free | awk '/^Mem:/ {print $2}')
mem_used=$(free | awk '/^Mem:/ {print $3}')
mem_usage=$(awk -v used="$mem_used" -v total="$mem_total" 'BEGIN { printf "%.2f", (used/total)*100 }')

# Get disk utilization in % for the root filesystem
# Example output: /dev/xvda1  80%
disk_usage=$(df -P / | awk 'NR==2 {print $5}' | tr -d '%')

# Print values
printf "CPU Usage: %s%%\n" "$cpu_usage"
printf "Memory Usage: %s%%\n" "$mem_usage"
printf "Disk Usage: %s%%\n" "$disk_usage"

# Check health condition: if any metric > THRESHOLD, VM is not healthy
if (( $(echo "$cpu_usage > $THRESHOLD" | bc -l) )) || (( $(echo "$mem_usage > $THRESHOLD" | bc -l) )) || (( $(echo "$disk_usage > $THRESHOLD" | bc -l) )); then
    echo "VM Health Status: NOT HEALTHY"
    exit 1
else
    echo "VM Health Status: HEALTHY"
    exit 0
fi
