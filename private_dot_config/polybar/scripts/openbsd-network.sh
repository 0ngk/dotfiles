#!/bin/sh

if [ "$(uname -s)" != "OpenBSD" ]; then
  printf '%%{T2}󰤯%%{T-} offline\n'
  exit 0
fi

iface=${WLAN_IFACE:-}

if [ -z "$iface" ]; then
  iface=$(ifconfig 2>/dev/null | awk '
    /^[[:alnum:]]+:/ {
      iface = $1
      sub(/:.*/, "", iface)
    }
    /groups:/ {
      for (i = 1; i <= NF; i++) {
        if ($i == "wlan") {
          print iface
          exit
        }
      }
    }
  ')
fi

if [ -z "$iface" ]; then
  printf '%%{T2}󰤯%%{T-} offline\n'
  exit 0
fi

ip=$(ifconfig "$iface" inet 2>/dev/null | awk '/inet / { print $2; exit }')

if [ -z "$ip" ]; then
  printf '%%{T2}󰤯%%{T-} %%{F#F0C674}%s%%{F#707880} disconnected\n' "$iface"
  exit 0
fi

# Get signal strength in dBm from ifconfig (e.g., "-65dBm")
signal=$(ifconfig "$iface" 2>/dev/null | awk '
  /ieee80211:/ {
    for (i = 1; i <= NF; i++) {
      if ($i ~ /^[-+][0-9]+dBm$/) {
        gsub(/[^0-9-]/, "", $i)
        print $i
        exit
      }
    }
  }
')

# Choose wifi strength icon based on dBm
if [ -n "$signal" ]; then
  if [ "$signal" -ge -50 ]; then
    icon="󰤨"  # wifi_strength_4 (strong)
  elif [ "$signal" -ge -60 ]; then
    icon="󰤥"  # wifi_strength_3 (good)
  elif [ "$signal" -ge -70 ]; then
    icon="󰤢"  # wifi_strength_2 (fair)
  elif [ "$signal" -ge -80 ]; then
    icon="󰤟"  # wifi_strength_1 (weak)
  else
    icon="󰤯"  # wifi_strength_outline (very weak)
  fi
else
  icon="󰤨"  # fallback: full strength
fi

nwid=$(ifconfig "$iface" 2>/dev/null | awk '
  {
    for (i = 1; i <= NF; i++) {
      if ($i == "nwid") {
        print $(i + 1)
        exit
      }
    }
  }
' | tr -d '"')

if [ -n "$nwid" ]; then
  printf '%%{T2}%s%%{T-} %%{F#F0C674}%s%%{F-} %s %s\n' "$icon" "$iface" "$nwid" "$ip"
else
  printf '%%{T2}%s%%{T-} %%{F#F0C674}%s%%{F-} %s\n' "$icon" "$iface" "$ip"
fi
