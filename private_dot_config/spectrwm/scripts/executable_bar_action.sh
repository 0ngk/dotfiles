#!/bin/sh

SLEEP_SECOND=60

while :; do
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
    printf "BAT %s%% %s %s\n" "$battery_percent" "$state" "$power"
  else
    printf "BAT unknown\n"
  fi

  sleep "$SLEEP_SECOND"
done
