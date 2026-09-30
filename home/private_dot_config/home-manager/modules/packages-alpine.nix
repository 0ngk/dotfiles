{pkgs, ...}:
with pkgs; [
  # Shell & terminal
  delta
  powershell

  # Language toolchains
  deno
  gleam
  gradle
  jdt-language-server
  mise
  nodejs
  pnpm
  yarn

  # Developer tools
  herdr

  # Compatibility tools
  unar

  # Editors & IDEs
  android-studio
  intellij-idea
  intellij-idea-oss
  jetbrains-toolbox
  vscode
  zed-editor

  # Developer tools
  # miniconda

  # Database & API clients
  datagrip
  sqlitebrowser
  dbeaver-bin
  httpie-desktop
  insomnia
  postman

  # Communication
  discord
  discord-ptb
  slack
  thunderbird

  # Productivity & knowledge
  anki
  calibre
  libreoffice
  obsidian

  # Creative & media
  audacity
  blender
  gimp
  inkscape
  obs-studio
  spotify
  vlc

  # Games
  prismlauncher
  steam

  # AI / agent CLIs
  agent-browser
  antigravity-cli
  claude-code
  codex
  pi-coding-agent
  github-copilot-cli

  # Security
  bitwarden-desktop
  burpsuite
  cloudflare-warp

  # Launcher
  vicinae
]
