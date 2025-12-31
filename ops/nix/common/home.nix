{ config, pkgs, lib, ... }:

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

    # AWS tools
    awscli2    # AWS CLI v2
    aws-vault  # AWS credential manager

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

    # Notifications
    libnotify  # Desktop notifications (notify-send command)

    # Theming
    tinty      # Base16/Base24 theme manager

    # Shell
    zsh        # Z shell
  ];

  # Starship prompt (Dracula theme)
  programs.starship = {
    enable = true;
    enableZshIntegration = true;
    settings = {
      "$schema" = "https://starship.rs/config-schema.json";

      format = "$directory$git_branch$git_state$git_status$cmd_duration$line_break$nix_shell$python$character";

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
        format = "[.venv]($style) ";
        style = "#6272a4";
        detect_extensions = [];
        detect_files = [];
      };

      nix_shell = {
        format = "[$symbol]($style)";
        symbol = "❄️";
        style = "bold #bd93f9";
        impure_msg = "";
        pure_msg = "";
        unknown_msg = "";
      };
    };
  };

  # Tmux Plugin Manager (tpm) setup
  # Clone tpm if not already present, allowing tmux plugins to work
  home.activation.cloneTpm = lib.hm.dag.entryAfter ["writeBoundary"] ''
    TPM_DIR="$HOME/.tmux/plugins/tpm"
    if [ ! -d "$TPM_DIR" ]; then
      $DRY_RUN_CMD mkdir -p "$HOME/.tmux/plugins"
      $DRY_RUN_CMD ${pkgs.git}/bin/git clone --depth 1 https://github.com/tmux-plugins/tpm "$TPM_DIR"
    fi
  '';

  # Let home-manager manage itself
  programs.home-manager.enable = true;

  # This value determines the home-manager release that your configuration is
  # compatible with. This helps avoid breakage when a new home-manager release
  # introduces backwards incompatible changes.
  home.stateVersion = "25.11";
}
