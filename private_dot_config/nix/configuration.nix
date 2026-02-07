{
  config,
  pkgs,
  username,
  ...
}: {
  # Platform
  nixpkgs.hostPlatform = "aarch64-darwin";

  # Nix configuration
  nix.settings = {
    experimental-features = "nix-command flakes";
  };

  nix.optimise.automatic = true;

  # System packages
  environment.systemPackages = with pkgs; [
    # Editors
    vim
    neovim
    emacs
    helix

    # Version control
    git
    gh
    git-filter-repo
    delta
    difftastic
    lazygit

    # Shell and terminal tools
    bat
    bottom
    dust
    fd
    ripgrep
    fzf
    tree
    procs
    peco
    zoxide
    tmux
    screen
    yazi
    eza
    lsd
    tre-command
    gomi
    terminal-notifier

    # Development tools
    gcc
    # gdb
    nodejs
    pnpm
    python313
    python314
    go
    gopls
    rust-analyzer
    erlang
    rebar3
    gleam
    biome
    stylua
    efm-langserver
    # pre-commit
    typos
    ruff
    clang-tools
    emmylua-ls
    alejandra

    # Network tools
    nmap
    socat
    httpie
    curl
    wget
    gping

    # Container tools
    docker
    docker-compose
    colima
    lima

    # Media tools
    ffmpeg
    imagemagick

    # File utilities
    jq
    yq

    # Modern CLI tools
    deno
    uv
    fastfetch
    onefetch
    chezmoi
    gibo
    zola
    dstp
    codex
    opencode

    # Other utilities
    gnupg
    nkf
    whois
    powershell
    bitwarden-cli
    byobu
    commitizen
    phpPackages.composer
    glances
    python313Packages.ipython
    markdownlint-cli2
    mercurial
    php
    phpactor
    pipx
    xdg-ninja
    superhtml
    bash-language-server
    shfmt
  ];

  # System defaults
  system.defaults = {
    # Global domain settings
    NSGlobalDomain = {
      # Interface
      AppleInterfaceStyle = "Dark";
      AppleShowAllExtensions = true;

      # Keyboard
      ApplePressAndHoldEnabled = false;
      KeyRepeat = 2;
      InitialKeyRepeat = 15;

      # Text input
      NSAutomaticCapitalizationEnabled = true;
      NSAutomaticDashSubstitutionEnabled = false;
      NSAutomaticPeriodSubstitutionEnabled = true;
      NSAutomaticQuoteSubstitutionEnabled = false;

      # Menu bar
      _HIHideMenuBar = true;
    };

    # Dock settings
    dock = {
      autohide = true;
      largesize = 16;
      magnification = false;
      minimize-to-application = true;
      mru-spaces = false;
      orientation = "bottom";
      show-recents = false;
      tilesize = 51;

      # Hot corners
      wvous-br-corner = 14; # Notification Center
    };

    # Finder settings
    finder = {
      AppleShowAllFiles = true;
      ShowPathbar = true;
      FXEnableExtensionChangeWarning = false;
      FXPreferredViewStyle = "Nlsv"; # List view
      ShowStatusBar = true;
    };

    # Trackpad settings
    trackpad = {
      Clicking = true;
      TrackpadRightClick = true;
      TrackpadThreeFingerDrag = false;
    };

    # Login window settings
    loginwindow = {
      GuestEnabled = false;
    };

    # Screencapture settings
    screencapture = {
      location = "~/Pictures/screenshots";
    };
  };

  # Keyboard settings
  system.keyboard = {
    enableKeyMapping = true;
  };

  # Security settings
  security.pam.services.sudo_local.touchIdAuth = true;

  # Homebrew integration
  homebrew = {
    enable = true;
    onActivation = {
      autoUpdate = true;
      upgrade = true;
      cleanup = "zap";
    };
    taps = [
      "jorgelbg/tap"
    ];

    # Formulae that are not available in nixpkgs or better managed by Homebrew
    brews = [
      "yabai"
      "sketchybar"
      "im-select"
      "pinentry-touchid"
      "hettysoft/tap/hetty"
      "winetricks"
    ];

    # Cask applications
    casks = [
      # Browsers
      "firefox"
      "firefox@developer-edition"
      "google-chrome"
      "microsoft-edge"

      # Terminals
      "wezterm"
      "ghostty"
      "warp"

      # Development
      "visual-studio-code"
      "intellij-idea"
      "intellij-idea-ce"
      "datagrip"
      "jetbrains-toolbox"
      "miniconda"

      # Communication
      "discord"
      "discord@ptb"
      "slack"
      "thunderbird"

      # Utilities
      "raycast"
      "rectangle"
      "karabiner-elements"
      "maccy"
      "jordanbaird-ice"
      "alt-tab"
      "aerospace"

      # Security
      "1password"
      "bitwarden"
      "burp-suite"

      # Virtualization
      "orbstack"
      "utm"

      # Productivity
      "obsidian"
      "notion"
      "anki"

      # Media
      "vlc"
      "spotify"
      "obs"

      # Other
      "claude"
      "claude-code"
      "chatgpt"
    ];
  };

  # Fonts
  fonts.packages = with pkgs; [
    (nerd-fonts.hack)
  ];

  # Programs
  programs.zsh.enable = true;
  programs.fish.enable = true;

  # Primary user
  system.primaryUser = username;

  # Users
  users.users.${username} = {
    name = username;
    home = "/Users/${username}";
    shell = pkgs.fish;
  };

  # System state version
  system.stateVersion = 6;

  # Set Git commit hash for darwin-version
  system.configurationRevision = null;
}
