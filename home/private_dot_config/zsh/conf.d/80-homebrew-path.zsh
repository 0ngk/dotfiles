# Prefer Homebrew-provided Node.js commands over nix-darwin wrappers.
# This file is sourced from .zshrc, so it applies to both login and
# non-login interactive zsh sessions.
if [[ "$OSTYPE" == darwin* ]]; then
  typeset -U path PATH
  path=(
    /opt/homebrew/bin(N-/)
    /opt/homebrew/sbin(N-/)
    $path
  )
fi
