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

    # Shell
    zsh        # Z shell
  ];

  # Starship prompt (Dracula theme)
  programs.starship = {
    enable = true;
    enableZshIntegration = true;
    settings = {
      aws.style = "bold #ffb86c";
      cmd_duration.style = "bold #f1fa8c";
      directory.style = "bold #50fa7b";
      hostname.style = "bold #ff5555";
      git_branch.style = "bold #ff79c6";
      git_status.style = "bold #ff5555";
      username = {
        format = "[$user]($style) on ";
        style_user = "bold #bd93f9";
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
