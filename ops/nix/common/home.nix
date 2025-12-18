{ config, pkgs, ... }:

{
  # Universal CLI tools for all hosts
  home.packages = with pkgs; [
    # Modern CLI replacements
    bat        # Better cat
    btop       # Better top
    fd         # Better find
    fzf        # Fuzzy finder
    ripgrep    # Better grep

    # Development essentials
    delta      # Better git diffs (git-delta)
    mise       # Version manager (node, python, etc.)
    neovim     # Text editor
    tmux       # Terminal multiplexer

    # File management
    ncdu       # Disk usage analyzer
    stow       # Dotfiles manager
    tree       # Directory tree viewer
    unzip      # Archive extraction
    vifm       # File manager

    # Data tools
    jq         # JSON processor
    sqlite     # Database CLI

    # Security
    gnupg      # GPG encryption
    pass       # Password manager

    # Network
    openssh    # SSH client

    # Compression
    pigz       # Parallel gzip

    # Documentation
    glow       # Markdown renderer

    # Shell
    zsh        # Z shell
  ];

  # Starship prompt (Dracula theme)
  programs.starship = {
    enable = true;
    enableZshIntegration = true;
    settings = {
      "$schema" = "https://starship.rs/config-schema.json";

      format = "$directory$git_branch$git_state$git_status$cmd_duration$line_break$python$character";

      directory = {
        style = "bold #bd93f9";
        truncation_length = 0;
        truncate_to_repo = false;
      };

      character = {
        success_symbol = "[❯](#ff79c6)";
        error_symbol = "[❯](#ff5555)";
        vimcmd_symbol = "[❮](#50fa7b)";
      };

      git_branch = {
        format = "[$branch]($style)";
        style = "#6272a4";
      };

      git_status = {
        format = "[[(*$conflicted$untracked$modified$staged$renamed$deleted)]($style) ($ahead_behind$stashed)]($style)";
        style = "#ff79c6";
        conflicted = "​";
        untracked = "​";
        modified = "​";
        staged = "​";
        renamed = "​";
        deleted = "​";
        stashed = "≡";
      };

      git_state = {
        format = ''\([$state( $progress_current/$progress_total)]($style)\) '';
        style = "#6272a4";
      };

      cmd_duration = {
        format = "[$duration]($style) ";
        style = "#f1fa8c";
      };

      python = {
        format = "[$virtualenv]($style) ";
        style = "#6272a4";
        detect_extensions = [];
        detect_files = [];
      };
    };
  };

  # Let home-manager manage itself
  programs.home-manager.enable = true;

  # This value determines the home-manager release that your configuration is
  # compatible with. This helps avoid breakage when a new home-manager release
  # introduces backwards incompatible changes.
  home.stateVersion = "25.11";
}
