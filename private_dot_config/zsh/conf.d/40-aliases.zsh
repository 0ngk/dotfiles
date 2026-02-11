# ========================================
# Aliases
# ========================================

# Navigation
alias b="cd .."
alias c="cd"
alias mkd="mkdir -p"

# File operations
# ezaの存在チェックを追加（より安全）
if command -v eza >/dev/null 2>&1; then
  alias ls="eza --icons=auto"
  alias la="eza --icons=auto -A"
  alias ll="eza --icons=auto -la"
fi

alias rm="gomi"
alias rmrm="command rm"

# Development Tools
alias br="brew"
alias cl="claude"
alias cm="chezmoi"
alias cmcd="cd ~/.local/share/chezmoi"
alias cdx="codex"
alias co="cargo"
alias dk="docker"
alias dkc="docker compose"
alias g="git"
alias gg="cz c"
alias gl="gleam"
alias lg="lazygit"
alias nv="nvim"
alias p="pnpm"
alias y="yarn"
alias yz="yazi"

# Configuration
alias fishconf="cd ~/.config/fish && nvim config.fish"
alias gconf="cd ~/.config/git && nvim config"
alias nvimconf="cd ~/.config/nvim && nvim init.lua"
alias zshconf="cd ~/.config/zsh && nvim .zshrc"

# Utilities
alias cf="copyfile"
alias ccu="pnpm dlx ccusage"
alias oc="opencode"
alias venv="source ./venv/bin/activate"  # Changed from activate.fish
alias wget="wget --hsts-file='$XDG_DATA_HOME/wget-hsts'"
alias wine="LANG=ja_JP.UTF-8 wine"
alias mvn="mvn -gs $XDG_CONFIG_HOME/maven/settings.xml"
alias adb='HOME="$XDG_DATA_HOME"/android adb'
