{
  config,
  pkgs,
  ...
}: {
  # Home Manager settings
  home.stateVersion = "24.11";

  # Environment variables
  home.sessionVariables = {
    # XDG Base Directory
    XDG_DATA_HOME = "$HOME/.local/share";
    XDG_CONFIG_HOME = "$HOME/.config";
    XDG_STATE_HOME = "$HOME/.local/state";
    XDG_CACHE_HOME = "$HOME/.cache";
    XDG_RUNTIME_DIR = "$TMPDIR";

    # # Shell
    # ZDOTDIR = "$XDG_CONFIG_HOME/zsh";
    # SHELL_SESSIONS_DISABLE = "1";
    # HISTFILE = "$XDG_STATE_HOME/zsh/history";

    # NPM
    NPM_CONFIG_INIT_MODULE = "$XDG_CONFIG_HOME/npm/config/npm-init.js";
    NPM_CONFIG_CACHE = "$XDG_CACHE_HOME/npm";
    NPM_CONFIG_TMP = "$XDG_RUNTIME_DIR/npm";
  };

  # Programs
  programs.home-manager.enable = true;

  # programs.zsh = {
  #   enable = true;
  #   enableCompletion = true;
  #   initContent = ''
  #     export GPG_TTY=$(tty)
  #   '';
  # };

  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
    enableFishIntegration = true;
  };

  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
    enableFishIntegration = true;
  };

  programs.bat = {
    enable = true;
  };

  programs.eza = {
    enable = true;
    enableZshIntegration = true;
    enableFishIntegration = true;
  };

  programs.gpg = {
    enable = true;
    homedir = "${config.xdg.dataHome}/gnupg";
    settings = {
      default-key = "85A6A9286F89E4C3!";
    };
  };

  services.gpg-agent = {
    enable = true;
    pinentry.package = pkgs.pinentry_mac;
    defaultCacheTtl = 3600;
    maxCacheTtl = 7200;
  };
}
