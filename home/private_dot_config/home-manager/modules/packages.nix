{
  pkgs,
  lib,
}:
with pkgs; [
  android-tools
  age

  # Shells
  bash
  fish
  zsh

  # Editors
  emacs
  helix
  vim
  neovim

  # Version control
  commitizen
  delta
  difftastic
  gh
  git
  git-filter-repo
  git-lfs
  lazygit
  mercurial

  # Shell essentials
  gomi
  zoxide

  # File search & navigation
  bat
  dust
  eza
  fd
  fzf
  lsd
  ripgrep
  tre-command
  tree
  yazi
  exiftool

  opencode

  # Terminal sessions
  byobu
  # kitty
  screen
  tmux
  zellij

  # Language runtimes & SDKs
  clang-tools
  dotnet-sdk_10
  beamPackages.erlang
  gcc
  go
  # javaPackages.compiler.openjdk21
  # javaPackages.compiler.openjdk25
  # javaPackages.compiler.temurin-bin.jdk-21
  javaPackages.compiler.temurin-bin.jdk-25
  kotlin
  lua
  nodejs
  php
  python314Packages.ipython
  python315
  rustup

  # Package managers & build tools
  gradle
  maven
  mise
  ni
  phpPackages.composer
  pipx
  rebar3
  typescript
  uv

  # Language servers & syntax tooling
  bash-language-server
  csharp-ls
  efm-langserver
  emmylua-ls
  fsautocomplete
  gopls
  lemminx
  phpactor
  roslyn-ls
  rust-analyzer
  sqls
  tinymist
  tree-sitter
  typescript-language-server
  vscode-css-languageserver
  yaml-language-server

  # Formatters & linters
  alejandra
  biome
  csharpier
  fantomas
  ktlint
  markdownlint-cli2
  # pre-commit
  ruff
  shellcheck
  shfmt
  stylua
  typos

  # Developer infrastructure
  supabase-cli

  # Network
  curl
  gping
  httpie
  nmap
  socat
  wget

  # Data, text & documents
  jq
  marp-cli
  nkf
  poppler
  # poppler-utils
  tesseract
  typst
  unzip
  yq
  zip
  zola

  # Media processing
  ffmpeg
  imagemagick

  # Security
  bitwarden-cli
  gnupg

  # System monitoring & info
  bottom
  btop
  fastfetch
  glances
  onefetch
  procs

  # AI / LLM
  ollama

  # Misc utilities
  chezmoi
  direnv
  nix-direnv
  dstp
  gibo
  kanata
  powershell
  rsync
  whois
  xdg-ninja
]
