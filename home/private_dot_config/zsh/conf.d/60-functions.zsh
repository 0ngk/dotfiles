# ========================================
# Custom Functions
# ========================================

# Create a directory and cd into it.
mkd() {
  local -a directories=("$@")
  mkdir -p -- "$@" || return
  cd -- "${directories[-1]}"
}

# Print arguments (Fish configuration compatibility).
tz() {
  print -r -- "$@"
}

# URL decode
urld() {
  print -rn -- "$*" | nkf -w --url-input
}

# URL encode
urle() {
  print -rn -- "$*" | nkf -WwMQ | tr '=' '%'
}

# Git Worktree
# Oh My Zsh's git plugin defines gwt as an alias.
unalias gwt 2>/dev/null || :
gwt() {
  if (($# != 3)); then
    echo "usage: gwt <repo> <start-point> <branch>" >&2
    return 1
  fi

  git worktree add \
    -b "local/$3" \
    "../secure/$1/$3" \
    "$2"
}
