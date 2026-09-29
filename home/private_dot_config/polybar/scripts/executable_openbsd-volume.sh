#!/bin/sh

if [ "$(uname -s)" != "OpenBSD" ]; then
  printf '%s\n' '--%'
  exit 0
fi

mute=$(sndioctl -n output.mute 2>/dev/null)

if [ "$mute" = "1" ]; then
  printf 'muted\n'
  exit 0
fi

level=$(sndioctl -n output.level 2>/dev/null)

if [ -z "$level" ]; then
  printf '%s\n' '--%'
  exit 0
fi

awk -v level="$level" 'BEGIN { printf "%d%%\n", level * 100 + 0.5 }'
