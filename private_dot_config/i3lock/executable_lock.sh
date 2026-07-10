#!/bin/sh

I3LOCK_BIN_PATH="/usr/local/bin/i3lock"
IMAGE="$HOME/Pictures/wallpapers/vars/lockscreen.png"

$I3LOCK_BIN_PATH \
  # --image="$IMAGE" \
  --color ff0000 \
  --ignore-empty-password \
  --show-failed-attempts
