{
  config,
  pkgs,
  username,
  ...
}: {
  # Platform
  nixpkgs.hostPlatform = "aarch64-darwin";
  nixpkgs.config = {
    allowUnsupportedSystem = true;
  };

  # Nix configuration
  nix.settings = {
    experimental-features = "nix-command flakes";
  };

  nix.optimise.automatic = true;

  nix.gc = {
    automatic = true;
    interval = [
      {
        Weekday = 7;
        Hour = 3;
        Minute = 15;
      }
    ];
    options = "--delete-older-than 30d";
  };

  # System packages
  environment.systemPackages = with pkgs; [
    # Editors
    emacs
    helix
    vim

    # Version control
    commitizen
    delta
    difftastic
    gh
    git
    git-lfs
    git-filter-repo
    lazygit
    mercurial

    # Shell & terminal
    bat
    bottom
    byobu
    dust
    eza
    fd
    fzf
    gomi
    lsd
    procs
    ripgrep
    screen
    terminal-notifier
    tmux
    tre-command
    tree
    yazi
    zoxide
    # kitty
    zellij

    # C/C++ ecosystem
    clang-tools
    gcc

    # Java & JVM ecosystem
    # javaPackages.compiler.openjdk21
    # javaPackages.compiler.openjdk25
    # gradle
    javaPackages.compiler.temurin-bin.jdk-21
    javaPackages.compiler.temurin-bin.jdk-25
    kotlin
    ktlint
    lemminx
    maven

    # JavaScript / TypeScript ecosystem
    biome
    ni
    nodejs
    pnpm
    typescript
    typescript-language-server
    vscode-css-languageserver

    # Python ecosystem
    pipx
    python313Packages.ipython
    python315
    ruff
    uv

    # Go ecosystem
    go
    gopls

    # .NET ecosystem
    csharp-ls
    csharpier
    dotnet-sdk_10
    fantomas
    fsautocomplete
    roslyn-ls

    # PHP ecosystem
    php
    phpactor
    phpPackages.composer

    # Erlang ecosystem
    erlang
    rebar3

    # Lua ecosystem
    emmylua-ls
    lua
    stylua

    # Typst ecosystem
    tinymist
    typst

    # Shell scripting ecosystem
    bash-language-server
    alejandra
    shellcheck
    shfmt

    # Generic language tooling
    efm-langserver
    markdownlint-cli2
    rust-analyzer
    tree-sitter
    typos
    yaml-language-server
    # pre-commit
    sqls

    # Network tools
    curl
    gping
    httpie
    nmap
    socat
    wget

    # Container tools
    colima
    docker
    docker-compose
    lima

    # Media tools
    ffmpeg
    imagemagick

    # Data tools
    jq
    yq
    tesseract
    poppler
    poppler-utils

    # Security
    bitwarden-cli
    gnupg

    # System info
    fastfetch
    glances
    onefetch

    # Utilities
    chezmoi
    dstp
    gibo
    kanata
    nkf
    powershell
    rsync
    whois
    xdg-ninja
    zola

    # supabase
    supabase-cli

    # Slides
    marp-cli

    # LLMs
    ollama
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
      expose-animation-duration = 0.1;
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

    # Accessibility settings
    universalaccess = {
      reduceMotion = true;
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
      cleanup = "none";
    };
    extraConfig = ''
      tap "jorgelbg/tap"
      tap "jetbrains/utils"
      tap "felixkratz/formulae"
      tap "oven-sh/bun"
      tap "hettysoft/tap"
      tap "daipeihust/tap"
      tap "docker/tap"
      tap "nikitabobko/tap"
      tap "TheBoredTeam/boring-notch"
      brew "jorgelbg/tap/pinentry-touchid", trusted: true
      brew "jetbrains/utils/kotlin-lsp", trusted: true
      brew "felixkratz/formulae/sketchybar", trusted: true
      brew "oven-sh/bun/bun", trusted: true
      brew "hettysoft/tap/hetty", trusted: true
      brew "daipeihust/tap/im-select", trusted: true
      cask "docker/tap/sbx", trusted: true
      cask "nikitabobko/tap/aerospace", trusted: true
      cask "TheBoredTeam/boring-notch/boring-notch", trusted: true
    '';

    # Formulae that are not available in nixpkgs or better managed by Homebrew
    brews = [
      # Shell & terminal
      "git-delta"
      "winetricks"
      # "yabai"

      # Language toolchains
      "gleam"
      "mise"
      "neovim"
      "jdtls"
      "npm"
      "yarn"
      "gradle"
      "deno"

      # Utilities
      "powershell"
      "unar"
      # "openjdk@21"
      # "openjdk@25"

      # LLMs
      "opencode"
      "openclaw-cli"
      "agent-browser"
    ];

    # Cask applications
    casks = [
      # Browsers
      "floorp"
      "firefox"
      "firefox@developer-edition"
      "google-chrome"
      "microsoft-edge"

      # Terminals
      "ghostty"
      "kitty"
      "wezterm"
      "warp"

      # Development
      "android-studio"
      "codex"
      "codex-app"
      "cursor-cli"
      "datagrip"
      "db-browser-for-sqlite"
      "fossa"
      "github"
      "insomnia"
      "intellij-idea"
      "intellij-idea-ce"
      "jetbrains-toolbox"
      "miniconda"
      "rustrover"
      "smoothcsv"
      "sourcetree"
      "visual-studio-code"
      "dbeaver-community"
      "postman"
      "zed"

      # Communication
      "deepl"
      "discord"
      "discord@ptb"
      "discord@canary"
      "microsoft-teams"
      "slack"
      "thunderbird"
      "zoom"

      # Utilities
      "alcom"
      "alt-tab"
      "amethyst"
      "azookey"
      "background-music"
      "commander-one"
      "jordanbaird-ice"
      "karabiner-elements"
      "localsend"
      "maccy"
      "openmtp"
      "raycast"
      "rectangle"
      # "wine@staging"
      "linear"

      # Security
      # "1password"
      "bitwarden"
      "burp-suite"
      "cloudflare-warp"

      # Virtualization
      # "orbstack"
      "utm"
      # "crossover"

      # Productivity
      "anki"
      "calibre"
      "libreoffice"
      "microsoft-office"
      "notion"
      "obsidian"
      "ticktick"
      "xmind"

      # Media
      "audacity"
      "blender"
      "epic-games"
      "gimp"
      "gstreamer-runtime"
      "handbrake-app"
      "httpie-desktop"
      "inkscape"
      "minecraft"
      "obs"
      "prismlauncher"
      "spotify"
      "steam"
      "unity-hub"
      "vlc"

      # Fonts
      "font-hack-nerd-font"
      "font-sketchybar-app-font"

      # Microsoft
      "microsoft-auto-update"
      "wireshark-app"
      "wine-stable"

      # LLMs
      "claude"
      "claude-code"
      "chatgpt"
      "copilot-cli"
      "chatgpt-atlas"
      "openclaw"
    ];
  };

  # Fonts
  fonts.packages = with pkgs; [
    (nerd-fonts.hack)
  ];

  # Programs
  # programs.zsh.enable = true;
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
