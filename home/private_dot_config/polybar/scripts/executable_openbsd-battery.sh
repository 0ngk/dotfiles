#!/bin/sh

MAX_CPU_MHZ=2400
BATTERY_ICON_COLOR="#CD9FF5"
LOW_POWER_ICON_COLOR="#F0C674"

if [ "$(uname -s)" != "OpenBSD" ]; then
  printf '%%{F#CD9FF5}%%{T2}%%{T-}%%{F-} --%%\n'
  exit 0
fi

percent=$(apm -l 2>/dev/null)
ac=$(apm -a 2>/dev/null)
status=$(apm -b 2>/dev/null)
current_mhz=$(apm 2>/dev/null | sed -n 's/.*Performance adjustment mode:.*(\([0-9][0-9]*\) MHz).*/\1/p')

if [ -z "$percent" ] || [ "$percent" = "255" ] || [ "$status" = "4" ]; then
  printf '%%{F#CD9FF5}%%{T2}%%{T-}%%{F-} no battery\n'
  exit 0
fi

# Determine icon based on charging state and percentage
if [ "$ac" = "1" ]; then
  icon=""  # charging bolt
elif [ "$percent" -lt 15 ]; then
  icon=""  # empty
elif [ "$percent" -lt 35 ]; then
  icon=""  # quarter
elif [ "$percent" -lt 60 ]; then
  icon=""  # half
elif [ "$percent" -lt 85 ]; then
  icon=""  # three quarters
else
  icon=""  # full
fi

icon_color="$BATTERY_ICON_COLOR"
if [ "$ac" != "1" ] && [ -n "$current_mhz" ] && [ "$current_mhz" -lt $((MAX_CPU_MHZ / 2)) ]; then
  icon_color="$LOW_POWER_ICON_COLOR"
fi

if [ "$ac" = "1" ]; then
  printf '%%{F#CD9FF5}%%{T2}%s%%{T-}%%{F-} AC %s%%\n' "$icon" "$percent"
else
  printf '%%{F%s}%%{T2}%s%%{T-}%%{F-} %s%%\n' "$icon_color" "$icon" "$percent"
fi
