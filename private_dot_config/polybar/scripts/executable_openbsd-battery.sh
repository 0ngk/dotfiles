#!/bin/sh

if [ "$(uname -s)" != "OpenBSD" ]; then
  printf '%s\n' '--%'
  exit 0
fi

percent=$(apm -l 2>/dev/null)
ac=$(apm -a 2>/dev/null)
status=$(apm -b 2>/dev/null)

if [ -z "$percent" ] || [ "$percent" = "255" ] || [ "$status" = "4" ]; then
  printf 'no battery\n'
  exit 0
fi

if [ "$ac" = "1" ]; then
  printf 'AC %s%%\n' "$percent"
else
  printf '%s%%\n' "$percent"
fi
