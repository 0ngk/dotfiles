#!/bin/sh

if [ "$(uname -s)" != "OpenBSD" ]; then
  printf 'offline\n'
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
  printf 'offline\n'
  exit 0
fi

ip=$(ifconfig "$iface" inet 2>/dev/null | awk '/inet / { print $2; exit }')

if [ -z "$ip" ]; then
  printf '%%{F#F0C674}%s%%{F#707880} disconnected\n' "$iface"
  exit 0
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
  printf '%%{F#F0C674}%s%%{F-} %s %s\n' "$iface" "$nwid" "$ip"
else
  printf '%%{F#F0C674}%s%%{F-} %s\n' "$iface" "$ip"
fi
