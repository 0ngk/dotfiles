{
  config,
  lib,
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
  environment.systemPackages =
    (import ../../modules/packages.nix {
      inherit pkgs lib;
    })
    ++ (import ../../modules/packages-darwin.nix {
      inherit pkgs lib;
    });

  # System defaults
  system.defaults = {
    menuExtraClock = {
      Show24Hour = true;
    };

    # Global domain settings
    NSGlobalDomain = {
      # Interface
      AppleInterfaceStyle = "Dark";
      AppleShowAllExtensions = true;
      AppleICUForce24HourTime = true;

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
      _HIHideMenuBar = false;
    };

    CustomUserPreferences = {
      NSGlobalDomain = {
        AppleLanguages = [
          "en-US"
        ];
        AppleLocale = "en-US";

        # Hide the menu bar only while an app is in full screen.
        AppleMenuBarVisibleInFullscreen = false;
      };
    };

    # The lock screen reads the system-wide global preferences.
    CustomSystemPreferences = {
      "/Library/Preferences/.GlobalPreferences" = {
        AppleICUForce24HourTime = true;
      };
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
      "neovim"
      "powershell"
      # "yabai"

      # Language toolchains
      "deno"
      "gleam"
      "gradle"
      "jdtls"
      "mise"
      "npm"
      "pnpm"
      "yarn"

      # Developer tools
      "herdr"

      # Compatibility tools
      "unar"
      "winetricks"
      # "openjdk@21"
      # "openjdk@25"

      # AI / agent CLIs
      "agent-browser"
      "openclaw-cli"
      "pi-coding-agent"
    ];

    # Cask applications
    casks = [
      # Browsers
      "firefox"
      "firefox@developer-edition"
      "floorp"
      "google-chrome"
      "microsoft-edge"

      # Terminals
      "ghostty"
      "kitty"
      "warp"
      "wezterm"

      # Editors & IDEs
      "android-studio"
      "intellij-idea"
      "intellij-idea-ce"
      "jetbrains-toolbox"
      # "rustrover"
      "visual-studio-code"
      "zed"

      # Developer tools
      "cursor-cli"
      "fossa"
      "github"
      "miniconda"
      "sourcetree"

      # Database & API clients
      "datagrip"
      "db-browser-for-sqlite"
      "dbeaver-community"
      "httpie-desktop"
      "insomnia"
      "postman"
      "smoothcsv"

      # Communication
      "deepl"
      "discord"
      "discord@canary"
      "discord@ptb"
      "microsoft-teams"
      "slack"
      "thunderbird"
      "zoom"

      # Productivity & knowledge
      "anki"
      "calibre"
      "libreoffice"
      "linear"
      "microsoft-office"
      "notion"
      "obsidian"
      "ticktick"
      "xmind"

      # System utilities
      "alcom"
      # "alt-tab"
      # "amethyst"
      "azookey"
      # "background-music"
      "commander-one"
      "jordanbaird-ice"
      "karabiner-elements"
      "localsend"
      "maccy"
      "openmtp"
      "raycast"
      # "rectangle"

      # Security & networking
      # "1password"
      "bitwarden"
      "burp-suite"
      "cloudflare-warp"
      "wireshark-app"

      # Virtualization
      # "orbstack"
      "utm"
      # "crossover"

      # Compatibility
      "wine-stable"
      # "wine@staging"

      # Creative & media
      "audacity"
      "blender"
      "gimp"
      "gstreamer-runtime"
      "handbrake-app"
      "inkscape"
      "obs"
      "spotify"
      "vlc"

      # Games
      # "epic-games"
      "minecraft"
      "prismlauncher"
      "steam"
      "unity-hub"

      # Fonts
      "font-hack-nerd-font"
      "font-sketchybar-app-font"

      # Microsoft
      "microsoft-auto-update"

      # AI apps
      "chatgpt"
      "claude"
      "claude-code"
      "codex"
      "codex-app"
      "copilot-cli"
      "openclaw"
      "antigravity"
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
