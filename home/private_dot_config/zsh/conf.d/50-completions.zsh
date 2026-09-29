# ========================================
# Completion Definitions
# ========================================

# Setup completions for command aliases
compdef _brew br 2>/dev/null
compdef _cargo co 2>/dev/null
compdef _docker dk 2>/dev/null
compdef _git g 2>/dev/null

# Setup eza completions for aliases (fallback to _ls if _eza is unavailable)
if command -v eza >/dev/null 2>&1; then
  eza_comp=0
  for _dir in $fpath; do
    if [[ -f "$_dir/_eza" ]]; then
      eza_comp=1
      break
    fi
  done
  if (( eza_comp )); then
    compdef _eza eza 2>/dev/null
    compdef _eza ls 2>/dev/null
    compdef _eza la 2>/dev/null
    compdef _eza ll 2>/dev/null
  else
    compdef _ls ls 2>/dev/null
    compdef _ls la 2>/dev/null
    compdef _ls ll 2>/dev/null
  fi
  unset eza_comp _dir
fi
