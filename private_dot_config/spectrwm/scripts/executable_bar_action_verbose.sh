#!/bin/sh

# Verbose debug version - outputs to both stdout (for bar) and stderr (for debugging)
# Run with: ./bar_action_verbose.sh 2>/tmp/bar_debug.log
# Then check: tail -f /tmp/bar_debug.log

SLEEP_SECOND=1

# State variables for delta calculations
prev_cpu_ticks=""
prev_net_rx=""
prev_net_tx=""
net_interface=""

log() {
  printf "[DEBUG] %s\n" "$*" >&2
}

# Get CPU usage percentage
get_cpu_usage() {
  log "=== CPU Start ==="
  cpu_ticks_raw="$(sysctl -n kern.cp_time 2>/dev/null)"
  log "Raw output: [$cpu_ticks_raw]"

  if [ -z "$cpu_ticks_raw" ]; then
    log "CPU: No output from sysctl"
    printf "CPU --%%"
    return 1
  fi

  # Convert comma-separated to space-separated
  cpu_ticks="$(printf "%s" "$cpu_ticks_raw" | tr ',' ' ')"
  log "After tr: [$cpu_ticks]"

  if [ -z "$prev_cpu_ticks" ]; then
    log "CPU: First run, saving ticks"
    prev_cpu_ticks="$cpu_ticks"
    printf "CPU --%%"
    return 0
  fi

  log "Prev ticks: [$prev_cpu_ticks]"
  log "Curr ticks: [$cpu_ticks]"

  # Parse current ticks: user nice sys intr idle
  set -- $cpu_ticks
  log "Field count: $#"
  if [ "$#" -lt 5 ]; then
    log "CPU: Not enough fields ($#)"
    printf "CPU ERR"
    return 1
  fi
  curr_user=$1 curr_nice=$2 curr_sys=$3 curr_intr=$4 curr_idle=$5
  log "Current: u=$curr_user n=$curr_nice s=$curr_sys i=$curr_intr idle=$curr_idle"

  # Parse previous ticks
  set -- $prev_cpu_ticks
  if [ "$#" -lt 5 ]; then
    log "CPU: Prev not enough fields, resetting"
    prev_cpu_ticks="$cpu_ticks"
    printf "CPU --%%"
    return 0
  fi
  prev_user=$1 prev_nice=$2 prev_sys=$3 prev_intr=$4 prev_idle=$5
  log "Previous: u=$prev_user n=$prev_nice s=$prev_sys i=$prev_intr idle=$prev_idle"

  # Calculate deltas
  user_delta=$((curr_user - prev_user))
  nice_delta=$((curr_nice - prev_nice))
  sys_delta=$((curr_sys - prev_sys))
  intr_delta=$((curr_intr - prev_intr))
  idle_delta=$((curr_idle - prev_idle))

  log "Deltas: u=$user_delta n=$nice_delta s=$sys_delta i=$intr_delta idle=$idle_delta"

  # Total delta
  total_delta=$((user_delta + nice_delta + sys_delta + intr_delta + idle_delta))
  log "Total delta: $total_delta"

  if [ "$total_delta" -eq 0 ]; then
    log "CPU: Zero delta"
    printf "CPU 0%%"
  else
    active_delta=$((user_delta + nice_delta + sys_delta + intr_delta))
    cpu_percent=$((active_delta * 100 / total_delta))
    log "Active delta: $active_delta, CPU: $cpu_percent%%"
    printf "CPU %d%%" "$cpu_percent"
  fi

  prev_cpu_ticks="$cpu_ticks"
  log "Saved prev_cpu_ticks: [$prev_cpu_ticks]"
}

# Get network traffic statistics
get_network_stats() {
  log "=== Network Start ==="

  if [ -z "$net_interface" ]; then
    iface="$(netstat -rn 2>/dev/null | awk '/^default/ {print $NF; exit}')"
    log "Detected interface: [$iface]"
    net_interface="$iface"
  else
    iface="$net_interface"
    log "Using cached interface: [$iface]"
  fi

  if [ -z "$iface" ]; then
    log "Network: No interface found"
    printf "NET --"
    return 1
  fi

  # Get RX and TX bytes
  net_stats="$(netstat -I "$iface" -bn 2>/dev/null | awk 'NR==2 && $3 == "<Link>" {print $5, $6}')"
  log "netstat output: [$net_stats]"

  if [ -z "$net_stats" ]; then
    log "Network: No stats from netstat -I"
    printf "NET --"
    return 1
  fi

  set -- $net_stats
  curr_rx="$1"
  curr_tx="$2"
  log "Current: RX=$curr_rx TX=$curr_tx"

  if [ -z "$curr_rx" ] || [ -z "$curr_tx" ]; then
    log "Network: Missing RX or TX"
    printf "NET --"
    return 1
  fi

  if [ -z "$prev_net_rx" ] || [ -z "$prev_net_tx" ]; then
    log "Network: First run, saving values"
    prev_net_rx="$curr_rx"
    prev_net_tx="$curr_tx"
    printf "NET --"
    return 0
  fi

  log "Previous: RX=$prev_net_rx TX=$prev_net_tx"

  # Calculate deltas
  rx_delta=$((curr_rx - prev_net_rx))
  tx_delta=$((curr_tx - prev_net_tx))
  log "Deltas: RX=$rx_delta TX=$tx_delta"

  # Handle counter wrapping
  if [ "$rx_delta" -lt 0 ]; then
    rx_delta=0
  fi
  if [ "$tx_delta" -lt 0 ]; then
    tx_delta=0
  fi

  # Convert to rate per second
  if [ "$SLEEP_SECOND" -gt 0 ]; then
    rx_rate=$((rx_delta / SLEEP_SECOND))
    tx_rate=$((tx_delta / SLEEP_SECOND))
  else
    rx_rate="$rx_delta"
    tx_rate="$tx_delta"
  fi
  log "Rates: RX=$rx_rate/s TX=$tx_rate/s"

  # Simple formatting (no functions for debugging)
  if [ "$rx_rate" -ge 1048576 ]; then
    rx_mb=$((rx_rate / 1048576))
    rx_fmt="${rx_mb}M"
  elif [ "$rx_rate" -ge 1024 ]; then
    rx_kb=$((rx_rate / 1024))
    rx_fmt="${rx_kb}K"
  else
    rx_fmt="${rx_rate}B"
  fi

  if [ "$tx_rate" -ge 1048576 ]; then
    tx_mb=$((tx_rate / 1048576))
    tx_fmt="${tx_mb}M"
  elif [ "$tx_rate" -ge 1024 ]; then
    tx_kb=$((tx_rate / 1024))
    tx_fmt="${tx_kb}K"
  else
    tx_fmt="${tx_rate}B"
  fi

  log "Formatted: RX=$rx_fmt TX=$tx_fmt"

  printf "NET ↓%s ↑%s" "$rx_fmt" "$tx_fmt"

  prev_net_rx="$curr_rx"
  prev_net_tx="$curr_tx"
  log "Saved prev: RX=$prev_net_rx TX=$prev_net_tx"
}

# Main loop
iter=0
while [ "$iter" -lt 5 ]; do
  iter=$((iter + 1))
  log "========== Iteration $iter =========="

  cpu="$(get_cpu_usage)"
  net="$(get_network_stats)"

  printf "%s | %s\n" "$cpu" "$net"

  sleep "$SLEEP_SECOND"
done

log "========== Done =========="
