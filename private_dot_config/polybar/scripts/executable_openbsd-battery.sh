#!/bin/sh

if [ "$(uname -s)" != "OpenBSD" ]; then
  printf '%%{F#CD9FF5}%%{T2}%%{T-}%%{F-} --%%\n'
  exit 0
fi

percent=$(apm -l 2>/dev/null)
ac=$(apm -a 2>/dev/null)
status=$(apm -b 2>/dev/null)

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

if [ "$ac" = "1" ]; then
  printf '%%{F#CD9FF5}%%{T2}%s%%{T-}%%{F-} AC %s%%\n' "$icon" "$percent"
else
  printf '%%{F#CD9FF5}%%{T2}%s%%{T-}%%{F-} %s%%\n' "$icon" "$percent"
fi
