# ========================================
# Oh My Zsh Configuration
# ========================================

# Oh My Zsh
export ZSH="${ZSH:-$XDG_CONFIG_HOME/zsh/ohmyzsh}"
ZSH_THEME="powerlevel10k/powerlevel10k"
plugins=(
  # Default plugins
  git
  copypath
  aliases
  copyfile

  # 3rd party plugins
  ## zsh-users
  zsh-autosuggestions
  zsh-syntax-highlighting
  zsh-completions
  ## MichaelAquilina
  you-should-use
)

# zsh-completions
# MUST BE BEFORE sourcing oh-my-zsh.sh
fpath+=${ZSH_CUSTOM:-${ZSH:-~/.oh-my-zsh}/custom}/plugins/zsh-completions/src

# Add nix-darwin completions
if [[ -d /etc/profiles/per-user/rei/share/zsh/site-functions ]]; then
  fpath+=(/etc/profiles/per-user/rei/share/zsh/site-functions)
fi

# Completion settings (before oh-my-zsh)
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path "$XDG_CACHE_HOME/zsh/zcompcache"
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|=*' 'l:|=* r:|=*'

# Set custom compdump path for oh-my-zsh
export ZSH_COMPDUMP="$XDG_CACHE_HOME/zsh/zcompdump-${ZSH_VERSION}"

source "$ZSH/oh-my-zsh.sh"
