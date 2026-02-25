#!/usr/bin/fish

# chezmoi cdの場合はcdしない
if not set -q CHEZMOI_SOURCE_DIR
  cd ~/
end

if status is-interactive
    # Commands to run in interactive sessions can go here
end

# Added by OrbStack: command-line tools and integration
# This won't be added again if you remove it.
# source ~/.orbstack/shell/init.zsh 2>/dev/null || :


# bind \cr history | fzf # Ctrl + r
bind \cr 'commandline -r (history | fzf)'

# Fish shell
set -g fish_prompt_pwd_dir_length      0
set -g theme_color_scheme              dracula
set -g theme_display_cmd_duration      no
set -g theme_display_git_master_branch yes
set -g theme_newline_cursor            yes

# Prompt separator line between cwd and input
# Random message function
function __random_prompt_message
    set -l messages \
        "Eclipse first, the rest nowhere." \
        "心不在焉，視而不見，聽而不聞，食而不知其味。" \
        "期待ではなく準備をする。"

    set -l random_index (random 1 (count $messages))
    echo $messages[$random_index]
end

# Update prompt message on every prompt display
function __update_random_prompt --on-event fish_prompt
    set -g theme_newline_prompt (begin; set_color --bold brcyan; printf '%s\n' (__random_prompt_message); set_color normal; printf '\n'; set_color --bold brcyan; printf '%s' '\n> '; set_color normal; end)
end

# xdg
set -gx XDG_DATA_HOME   $HOME/.local/share
set -gx XDG_CONFIG_HOME $HOME/.config
set -gx XDG_STATE_HOME  $HOME/.local/state
set -gx XDG_CACHE_HOME  $HOME/.cache
set -gx XDG_RUNTIME_DIR $TMPDIR

# bash
set -gx HISTFILE $XDG_STATE_HOME/bash/history

# GPG
set -gx GPG_TTY   $(tty)
set -gx GNUPGHOME $XDG_DATA_HOME/gnupg

# Homebrew
# eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
if test "$__platform" = "macos"
  eval "$(/opt/homebrew/bin/brew shellenv)"
end


# Editor
set -gx EDITOR nvim

# Vim
# set -gx VIM $XDG_CONFIG_HOME/vim

# Binary files
fish_add_path /usr/bin/


# Wine
set -gx WINEPREFIX $XDG_DATA_HOME/wine


# JetBrains
# Added by Toolbox App
if test "$__platform" = "macos"
  fish_add_path $HOME/Library/Application Support/JetBrains/Toolbox/scripts
end


# Rust
set -gx CARGO_HOME  $XDG_DATA_HOME/cargo
set -gx RUSTUP_HOME $XDG_DATA_HOME/rustup
fish_add_path $CARGO_HOME/bin $rust_path

# Python
set -gx IPYTHONDIR        $XDG_CONFIG_HOME/ipython
set -gx JUPYTER_CONFIG_DIR $XDG_CONFIG_HOME/jupyter
set -gx PYTHONSTARTUP     $XDG_CONFIG_HOME/python/pythonrc
set -gx MPLCONFIGDIR      $XDG_CONFIG_HOME/matplotlib
set -gx PYTHON_HISTORY $XDG_STATE_HOME/python/history
fish_add_path $HOME/.local/lib/python3.8/site-packages
fish_add_path /usr/lib/python3/dist-packages
fish_add_path $HOME/Library/Python/3.9/bin

# Ruby
fish_add_path $HOME/.rvm/bin
# rvm default

# Yarn
fish_add_path $HOME/.yarn/bin

# Go
set -gx GOPATH $XDG_DATA_HOME/go
fish_add_path /usr/local/go/bin
fish_add_path $GOPATH
fish_add_path $GOPATH/bin

# pipx
set PATH $PATH $HOME/.local/bin

# npm
set -gx NPM_CONFIG_INIT_MODULE $XDG_CONFIG_HOME/npm/config/npm-init.js
set -gx NPM_CONFIG_CACHE       $XDG_CACHE_HOME/npm
set -gx NPM_CONFIG_TMP         $XDG_RUNTIME_DIR/npm

# pnpm
set -gx PNPM_HOME $HOME/.local/share/pnpm
# Nix版pnpmを使用するため、PNPM_HOME自体はPATHに追加しない
# グローバルパッケージのbinディレクトリのみPATHに追加
fish_add_path $PNPM_HOME/node_modules/.bin
fish_add_path $HOME/.local/share/pnpm

# nodejs
set -gx NODE_REPL_HISTORY $XDG_STATE_HOME/node_repl_history

# gradle
set -gx GRADLE_USER_HOME $XDG_DATA_HOME/gradle

# maven
alias mvn "mvn -gs $XDG_CONFIG_HOME/maven/settings.xml"

# wakatime
set -gx WAKATIME_HOME $XDG_CONFIG_HOME/wakatime

# dotnet
if command -sq dotnet
    set -l dotnet_bin (command -s dotnet)
    set -l dotnet_real_bin ""

    # Nix often exposes a wrapper under `.../bin`, but apphosts need the actual runtime root.
    if command -sq realpath
        set dotnet_real_bin (realpath "$dotnet_bin" 2>/dev/null)
    end

    if test -n "$dotnet_real_bin"; and test -x "$dotnet_real_bin"
        set -gx DOTNET_ROOT (dirname "$dotnet_real_bin")
    else
        set -gx DOTNET_ROOT (dirname "$dotnet_bin")
    end
else
    set -gx DOTNET_ROOT $XDG_DATA_HOME/dotnet
end
set -gx DOTNET_CLI_HOME $XDG_DATA_HOME/dotnet
fish_add_path $DOTNET_CLI_HOME/.dotnet/tools

# php
set -gx COMPOSER_HOME $XDG_CONFIG_HOME/composer
fish_add_path $COMPOSER_HOME/vendor/bin

# sonarlint
set -gx SONARLINT_USER_HOME $XDG_DATA_HOME/sonarlint

# android
set -gx ANDROID_USER_HOME $XDG_DATA_HOME/android
alias adb 'HOME="$XDG_DATA_HOME"/android adb'

# docker
set -gx DOCKER_CONFIG $XDG_CONFIG_HOME/docker

# less
set -gx LESSHISTFILE $XDG_STATE_HOME/less/history

# zsh
set -gx ZDOTDIR $XDG_CONFIG_HOME/zsh

# Aliases
alias b        "cd .."
alias br       "brew"
alias c        "cd"
alias ccu      "pnpm dlx ccusage"
alias cl       "claude"
alias cm       "chezmoi"
alias cmcd     "cd ~/.local/share/chezmoi"
alias cdx      "codex"
alias co       "cargo"
alias dk       "docker"
alias dkc      "docker compose"
alias f        "fish"
alias fishconf "cd ~/.config/fish && nvim config.fish"
alias g        "git"
alias gg       "cz c"
alias gl       "gleam"
alias gconf    "cd ~/.config/git && nvim config"
alias la       "ls --icons -A"
alias lg       "lazygit"
alias ll       "ls --icons -la"
alias ls       "eza --icons"
alias mkd      "mkdir -p"
alias nv       "nvim"
alias nvimconf "cd ~/.config/nvim && nvim init.lua"
alias oc       "opencode"
alias p        "pnpm"
alias rm       "gomi"
alias rmrm     "/bin/rm"
alias venv     "source ./venv/bin/activate.fish"
alias wget     "wget --hsts-file='$XDG_DATA_HOME/wget-hsts'"
alias wine     "LANG=ja_JP.UTF-8 wine"
alias y        "yarn"
alias yz       "yazi"


# Functions
function urld
  echo $argv | nkf -w --url-input
end

function urle
  echo $argv | nkf -WwMQ | tr = %
end

# tar gz
function tz
  echo $argv
end

# zoxide (must be placed in the last line)
zoxide init fish | source
