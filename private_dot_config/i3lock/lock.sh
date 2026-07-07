#!/bin/sh

I3LOCK_BIN_PATH="/usr/local/bin/i3lock"
IMAGE="$HOME/Pictures/wallpapers/lockscreen.png"

exec $I3LOCK_BIN_PATH \
  --image="$IMAGE" \
  --ignore-empty-password \
  --show-failed-attempts
