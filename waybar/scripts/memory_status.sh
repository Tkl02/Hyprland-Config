#!/usr/bin/env bash

set -euo pipefail

json_escape() {
  sed -e 's/\\/\\\\/g' -e 's/"/\\"/g' -e ':a;N;$!ba;s/\n/\\n/g'
}

total_kb=$(awk '/MemTotal:/ {print $2}' /proc/meminfo)
avail_kb=$(awk '/MemAvailable:/ {print $2}' /proc/meminfo)
used_kb=$((total_kb - avail_kb))

used_gb=$(awk -v kb="$used_kb" 'BEGIN { printf "%.1f", kb/1024/1024 }')
total_gb=$(awk -v kb="$total_kb" 'BEGIN { printf "%.1f", kb/1024/1024 }')
used_pct=$(awk -v used="$used_kb" -v total="$total_kb" 'BEGIN { printf "%.0f", (used/total)*100 }')

state="normal"
if [ "$used_pct" -ge 85 ]; then
  state="critical"
elif [ "$used_pct" -ge 70 ]; then
  state="warning"
fi

top_apps=$(ps -eo comm=,rss= --no-headers \
  | awk '{mem[$1]+=$2} END {for (app in mem) printf "%.0f\t%s\n", mem[app]/1024, app}' \
  | sort -nr \
  | head -n 8 \
  | awk '{printf "%-18s %5d MB\n", $2, $1}')

tooltip=$(printf "Uso de memoria: %s%% (%sG/%sG)\n\nTop apps por RAM:\n%s" "$used_pct" "$used_gb" "$total_gb" "$top_apps")

printf '{"text":"%s%% %sG/%sG","class":"%s","tooltip":"%s"}\n' \
  "$used_pct" "$used_gb" "$total_gb" "$state" "$(printf "%s" "$tooltip" | json_escape)"