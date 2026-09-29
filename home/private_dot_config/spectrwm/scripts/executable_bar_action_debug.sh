#!/bin/sh

# Debug version of bar_action.sh with logging
# Run this instead of bar_action.sh to see what's happening
# Log file: /tmp/bar_action_debug.log

SLEEP_SECOND=1
LOGFILE="/tmp/bar_action_debug.log"

# Clear log file
> "$LOGFILE"

log() {
  printf "[%s] %s\n" "$(date '+%H:%M:%S')" "$*" >> "$LOGFILE"
}

# State variables for delta calculations
prev_cpu_ticks=""
prev_net_rx=""
prev_net_tx=""
net_interface=""

log "=== Bar Action Debug Started ==="

# Test CPU
log "Testing CPU command..."
cpu_output="$(sysctl -n kern.cp_time 2>&1)"
log "sysctl -n kern.cp_time: $cpu_output"

# Test network
log "Testing network commands..."
log "netstat -rn | grep default:"
netstat -rn 2>&1 | grep '^default' >> "$LOGFILE"

default_iface="$(netstat -rn 2>/dev/null | awk '/^default/ {print $NF; exit}')"
log "Detected interface: $default_iface"

if [ -n "$default_iface" ]; then
  log "netstat -I $default_iface -bn:"
  netstat -I "$default_iface" -bn 2>&1 >> "$LOGFILE"

  log "Parsing network stats..."
  net_stats="$(netstat -I "$default_iface" -bn 2>/dev/null | awk 'NR==2 && $3 == "<Link>" {print "RX:", $7, "TX:", $10}')"
  log "Parsed stats: $net_stats"
fi

log "netstat -ibn (first 5 lines):"
netstat -ibn 2>&1 | head -n 5 >> "$LOGFILE"

log "=== Starting main loop ==="

# Source the actual functions from bar_action.sh
. /Users/rei/.config/spectrwm/scripts/bar_action.sh 2>/dev/null || {
  log "ERROR: Could not source bar_action.sh"
  exit 1
}
