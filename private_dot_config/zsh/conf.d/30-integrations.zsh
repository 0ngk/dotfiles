# ========================================
# External Integrations
# ========================================

# GPG Configuration
# GPG_TTYは対話シェルでのみ設定（非対話シェルでのエラー回避）
if [[ -t 1 ]]; then
  export GPG_TTY="$(tty)"
fi

# ========================================
# Rust
# ========================================
if [[ -f "$HOME/.local/share/cargo/env" ]]; then
  . "$HOME/.local/share/cargo/env"
fi

# ========================================
# Zoxide
# ========================================
eval "$(zoxide init zsh)"
