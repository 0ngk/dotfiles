#!/bin/sh

SLEEP_SECOND=1

# State file for persistent data across function calls
STATE_FILE="/tmp/bar_action_state_$$"

# Initialize state file
if [ ! -f "$STATE_FILE" ]; then
  printf "prev_cpu_ticks=\nprev_net_rx=\nprev_net_tx=\nnet_interface=\n" > "$STATE_FILE"
fi

# Cleanup on exit
trap 'rm -f "$STATE_FILE"' EXIT INT TERM

# Load state
load_state() {
  if [ -f "$STATE_FILE" ]; then
    . "$STATE_FILE"
  fi
}

# Save state
save_state() {
  printf "prev_cpu_ticks='%s'\nprev_net_rx='%s'\nprev_net_tx='%s'\nnet_interface='%s'\n" \
    "$prev_cpu_ticks" "$prev_net_rx" "$prev_net_tx" "$net_interface" > "$STATE_FILE"
}

# Get CPU usage percentage
get_cpu_usage() {
  load_state

  cpu_ticks="$(sysctl -n kern.cp_time 2>/dev/null)"

  if [ -z "$cpu_ticks" ]; then
    printf "CPU --%%"
    return 1
  fi

  # Convert comma-separated to space-separated
  cpu_ticks="$(printf "%s" "$cpu_ticks" | tr ',' ' ')"

  if [ -z "$prev_cpu_ticks" ]; then
    prev_cpu_ticks="$cpu_ticks"
    save_state
    printf "CPU --%%"
    return 0
  fi

  # Parse current ticks: user nice sys intr idle
  set -- $cpu_ticks
  if [ "$#" -lt 5 ]; then
    printf "CPU ERR"
    return 1
  fi
  curr_user=$1 curr_nice=$2 curr_sys=$3 curr_intr=$4 curr_idle=$5

  # Parse previous ticks
  set -- $prev_cpu_ticks
  if [ "$#" -lt 5 ]; then
    prev_cpu_ticks="$cpu_ticks"
    printf "CPU --%%"
    return 0
  fi
  prev_user=$1 prev_nice=$2 prev_sys=$3 prev_intr=$4 prev_idle=$5

  # Calculate deltas
  user_delta=$((curr_user - prev_user))
  nice_delta=$((curr_nice - prev_nice))
  sys_delta=$((curr_sys - prev_sys))
  intr_delta=$((curr_intr - prev_intr))
  idle_delta=$((curr_idle - prev_idle))

  # Total delta
  total_delta=$((user_delta + nice_delta + sys_delta + intr_delta + idle_delta))

  if [ "$total_delta" -eq 0 ]; then
    printf "CPU 0%%"
  else
    active_delta=$((user_delta + nice_delta + sys_delta + intr_delta))
    cpu_percent=$((active_delta * 100 / total_delta))
    printf "CPU %d%%" "$cpu_percent"
  fi

  prev_cpu_ticks="$cpu_ticks"
  save_state
}

# Get memory usage
get_memory_usage() {
  # Using top to get memory info
  mem_info="$(top -b -1 2>/dev/null | grep -i 'memory:' | head -n 1)" || return 1

  if [ -z "$mem_info" ]; then
    printf "MEM --"
    return 1
  fi

  # Parse memory info (format varies, attempt to extract used/total)
  # Typical format: "Memory: Real: 123M/456M act/tot Free: 333M Cache: 100M Swap: 0K/1024M"
  total_mb="$(printf "%s" "$mem_info" | sed -n 's/.*\/\([0-9]*\)M.*/\1/p' | head -n 1)"
  used_mb="$(printf "%s" "$mem_info" | sed -n 's/.*Real: \([0-9]*\)M.*/\1/p')"

  if [ -n "$total_mb" ] && [ -n "$used_mb" ]; then
    # Convert to GB if > 1024MB
    if [ "$total_mb" -ge 1024 ]; then
      if command -v bc >/dev/null 2>&1; then
        total_gb="$(echo "scale=1; $total_mb/1024" | bc)"
        used_gb="$(echo "scale=1; $used_mb/1024" | bc)"
        printf "MEM %sG/%sG" "$used_gb" "$total_gb"
      else
        total_gb=$((total_mb / 1024))
        used_gb=$((used_mb / 1024))
        printf "MEM %dG/%dG" "$used_gb" "$total_gb"
      fi
    else
      printf "MEM %dM/%dM" "$used_mb" "$total_mb"
    fi
  else
    printf "MEM --"
  fi
}

# Get load average
get_load_average() {
  load="$(sysctl -n vm.loadavg 2>/dev/null)" || return 1

  # Extract 1-minute load average (first number)
  load_1min="$(printf "%s" "$load" | awk '{print $1}')"

  if [ -n "$load_1min" ]; then
    printf "LOAD %s" "$load_1min"
  else
    printf "LOAD --"
  fi
}

# Format bytes with appropriate units (K/M/G)
format_bytes() {
  bytes="$1"
  if [ "$bytes" -ge 1073741824 ]; then
    # GB - use bc if available, otherwise integer math
    if command -v bc >/dev/null 2>&1; then
      printf "%.1fG" "$(echo "scale=1; $bytes/1073741824" | bc)"
    else
      gb=$((bytes / 1073741824))
      printf "%dG" "$gb"
    fi
  elif [ "$bytes" -ge 1048576 ]; then
    # MB
    if command -v bc >/dev/null 2>&1; then
      printf "%.1fM" "$(echo "scale=1; $bytes/1048576" | bc)"
    else
      mb=$((bytes / 1048576))
      printf "%dM" "$mb"
    fi
  elif [ "$bytes" -ge 1024 ]; then
    # KB
    kb=$((bytes / 1024))
    printf "%dK" "$kb"
  else
    printf "%dB" "$bytes"
  fi
}

# Auto-detect active network interface
get_active_interface() {
  load_state

  if [ -n "$net_interface" ]; then
    printf "%s" "$net_interface"
    return 0
  fi

  # Try to get default route interface
  iface="$(netstat -rn 2>/dev/null | awk '/^default/ {print $NF; exit}')"

  if [ -z "$iface" ]; then
    # Fallback: find first non-loopback interface with traffic
    iface="$(netstat -ibn 2>/dev/null | awk '$1 !~ /^lo/ && $1 ~ /^[a-z]/ && ($5 > 0 || $6 > 0) {print $1; exit}')"
  fi

  net_interface="$iface"
  printf "%s" "$iface"
}

# Get network traffic statistics
get_network_stats() {
  load_state

  iface="$(get_active_interface)"

  if [ -z "$iface" ]; then
    printf "NET --"
    return 1
  fi

  # Get RX and TX bytes for the interface (using -I flag to specify interface)
  # Format: netstat -I interface -bn shows stats for specific interface
  # Columns: Name Mtu Network Address Ibytes Obytes
  #          1    2   3       4       5      6
  net_stats="$(netstat -I "$iface" -bn 2>/dev/null | awk 'NR==2 && $3 == "<Link>" {print $5, $6}')"

  if [ -z "$net_stats" ]; then
    # Fallback to parsing all interfaces
    net_stats="$(netstat -ibn 2>/dev/null | awk -v iface="$iface" '$1 == iface && $3 == "<Link>" {print $5, $6; exit}')"
  fi

  if [ -z "$net_stats" ]; then
    printf "NET --"
    return 1
  fi

  set -- $net_stats
  curr_rx="$1"
  curr_tx="$2"

  # Validate that we got numbers
  if [ -z "$curr_rx" ] || [ -z "$curr_tx" ]; then
    printf "NET --"
    return 1
  fi

  if [ -z "$prev_net_rx" ] || [ -z "$prev_net_tx" ]; then
    prev_net_rx="$curr_rx"
    prev_net_tx="$curr_tx"
    save_state
    printf "NET --"
    return 0
  fi

  # Calculate deltas
  rx_delta=$((curr_rx - prev_net_rx))
  tx_delta=$((curr_tx - prev_net_tx))

  # Handle counter wrapping (negative delta)
  if [ "$rx_delta" -lt 0 ]; then
    rx_delta=0
  fi
  if [ "$tx_delta" -lt 0 ]; then
    tx_delta=0
  fi

  # Convert to rate per second (divide by sleep interval)
  if [ "$SLEEP_SECOND" -gt 0 ]; then
    rx_rate=$((rx_delta / SLEEP_SECOND))
    tx_rate=$((tx_delta / SLEEP_SECOND))
  else
    rx_rate="$rx_delta"
    tx_rate="$tx_delta"
  fi

  rx_formatted="$(format_bytes "$rx_rate")"
  tx_formatted="$(format_bytes "$tx_rate")"

  printf "NET ↓%s ↑%s" "$rx_formatted" "$tx_formatted"

  prev_net_rx="$curr_rx"
  prev_net_tx="$curr_tx"
  save_state
}

# Get volume level
get_volume() {
  # Try sndioctl first (OpenBSD 7.0+)
  if command -v sndioctl >/dev/null 2>&1; then
    vol_level="$(sndioctl -n output.level 2>/dev/null)"

    if [ -n "$vol_level" ]; then
      # Convert 0.0-1.0 to percentage
      if command -v bc >/dev/null 2>&1; then
        vol_percent="$(echo "$vol_level * 100 / 1" | bc)"
      else
        # Fallback: try to parse as integer (some implementations might return 0-100)
        vol_percent="$(printf "%.0f" "$vol_level" 2>/dev/null)" || vol_percent="50"
      fi

      # Check if muted
      vol_mute="$(sndioctl -n output.mute 2>/dev/null)"
      if [ "$vol_mute" = "1" ]; then
        printf "VOL MUTE"
      else
        printf "VOL %d%%" "$vol_percent"
      fi
      return 0
    fi
  fi

  # Fallback to mixerctl
  if command -v mixerctl >/dev/null 2>&1; then
    vol_info="$(mixerctl -n outputs.master 2>/dev/null)"

    if [ -n "$vol_info" ]; then
      # Parse format like "255,255" (left,right)
      vol_left="$(printf "%s" "$vol_info" | cut -d',' -f1)"

      # Assume max is 255, convert to percentage
      vol_percent=$((vol_left * 100 / 255))
      printf "VOL %d%%" "$vol_percent"
      return 0
    fi
  fi

  printf "VOL --"
}

# Get currently playing media info
get_media_info() {
  # Try playerctl first
  if command -v playerctl >/dev/null 2>&1; then
    # Check if any player is playing
    player_status="$(playerctl status 2>/dev/null)"

    if [ "$player_status" = "Playing" ]; then
      media="$(playerctl metadata --format '{{ artist }} - {{ title }}' 2>/dev/null)"

      if [ -n "$media" ]; then
        # Truncate if too long
        if [ "${#media}" -gt 40 ]; then
          media="$(printf "%.37s..." "$media")"
        fi
        printf "♪ %s" "$media"
        return 0
      fi
    fi
  fi

  # No media playing or playerctl not available
  return 1
}

# Get focused application name
get_focused_app() {
  # Try xdotool first
  if command -v xdotool >/dev/null 2>&1; then
    app_name="$(xdotool getwindowfocus getwindowname 2>/dev/null)"
  elif command -v xprop >/dev/null 2>&1; then
    # Fallback to xprop
    active_window="$(xprop -root _NET_ACTIVE_WINDOW 2>/dev/null | cut -d' ' -f5)"
    if [ -n "$active_window" ]; then
      app_name="$(xprop -id "$active_window" WM_NAME 2>/dev/null | cut -d'"' -f2)"
    fi
  fi

  if [ -n "$app_name" ]; then
    # Truncate if too long
    if [ "${#app_name}" -gt 30 ]; then
      app_name="$(printf "%.27s..." "$app_name")"
    fi
    printf "[%s]" "$app_name"
  else
    printf "[--]"
  fi
}

# Get battery information (refactored from original)
get_battery_info() {
  battery_percent="$(apm -l 2>/dev/null)"
  battery_ac_connection="$(apm -a 2>/dev/null)"
  battery_status="$(apm -b 2>/dev/null)"

  # AC:
  # - 0  : disconnected,
  # - 1  : connected,
  # - 2  : backup,
  # - 255: unknown
  case "$battery_ac_connection" in
    1) power="AC" ;;
    0) power="BAT" ;;
    2) power="UPS" ;;
    *) power="UNK" ;;
  esac

  # Battery:
  # - 0  : high
  # - 1  : low
  # - 2  : critical
  # - 3  : charging
  # - 4  : absent
  # - 255: unknown
  case "$battery_status" in
    3) state="CHG" ;;
    0) state="HIGH" ;;
    1) state="LOW" ;;
    2) state="CRIT" ;;
    4) state="ABS" ;;
    *) state="UNK" ;;
  esac

  if [ -n "$battery_percent" ]; then
    printf "BAT %s%% %s %s" "$battery_percent" "$state" "$power"
  else
    printf "BAT --"
  fi
}

# Main loop
while :; do
  # Collect all metrics
  focused="$(get_focused_app)"
  cpu="$(get_cpu_usage)"
  mem="$(get_memory_usage)"
  load="$(get_load_average)"
  net="$(get_network_stats)"
  vol="$(get_volume)"
  bat="$(get_battery_info)"

  # Get media info (only if playing)
  media="$(get_media_info)"

  # Format output
  printf "%s | %s | %s | %s | %s" "$focused" "$cpu" "$mem" "$load" "$net"

  # Add media info if available
  if [ -n "$media" ]; then
    printf " | %s" "$media"
  fi

  printf " | %s | %s\n" "$vol" "$bat"

  sleep "$SLEEP_SECOND"
done
