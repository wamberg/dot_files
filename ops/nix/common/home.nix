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

  # Let home-manager manage itself
  programs.home-manager.enable = true;

  # This value determines the home-manager release that your configuration is
  # compatible with. This helps avoid breakage when a new home-manager release
  # introduces backwards incompatible changes.
  home.stateVersion = "25.11";
}
