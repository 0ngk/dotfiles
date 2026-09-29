# ========================================
# Key Bindings
# ========================================

# fzf history search with Ctrl+R
fzf-history-widget() {
  LBUFFER=$(history -n 1 | fzf --tac --no-sort)
  zle redisplay
}
zle -N fzf-history-widget
bindkey '^R' fzf-history-widget
