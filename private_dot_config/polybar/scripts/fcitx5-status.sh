#!/bin/sh

name=$(fcitx5-remote -n 2>/dev/null) || { echo "?"; exit 0; }

case "$name" in
  *keyboard*|*us*) echo "A" ;;
  *mozc*|*anthy*)  printf '%%{T3}あ%%{T-}\n' ;;
  *)               echo "${name:-?}" ;;
esac
