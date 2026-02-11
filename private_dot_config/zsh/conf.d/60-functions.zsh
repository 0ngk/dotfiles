# ========================================
# Custom Functions
# ========================================

# URL decode
urld() {
  print -rn -- "$*" | nkf -w --url-input
}

# URL encode
urle() {
  print -rn -- "$*" | nkf -WwMQ | tr '=' '%'
}
