{pkgs, ...}:
with pkgs; [
  # Notification utility
  terminal-notifier

  # Developer infrastructure
  docker
  docker-compose
  colima
  lima
]
