{ config, pkgs, lib, ... }:

{
  # Universal CLI tools for all hosts
  home.packages = with pkgs; [
    # Modern CLI replacements
    bat        # Better cat
    fd         # Better find
    fzf        # Fuzzy finder
    ripgrep    # Better grep

    # Development essentials
    delta      # Better git diffs (git-delta)
    mise       # Version manager (node, python, etc.)
    neovim     # Text editor
    tree-sitter  # TreeSitter CLI (for parser compilation)
    tmux       # Terminal multiplexer

    # LSP servers and formatters for neovim
    htmx-lsp             # HTMX LSP
    lua-language-server  # Lua LSP
    stylua               # Lua formatter
    ty                   # Python LSP and type checker
    nodePackages.typescript-language-server  # TypeScript/JavaScript LSP

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

    # Theming
    tinty      # Base16/Base24 theme manager

    # Shell
    zsh        # Z shell
  ] ++ lib.optionals pkgs.stdenv.isLinux [
    # Linux-only packages
    libnotify  # Desktop notifications (notify-send command)
  ];

  # Starship prompt
  # Configuration managed via stow from starship/.config/starship.toml
  # Colors updated automatically by tinty hooks
  programs.starship = {
    enable = true;
    enableZshIntegration = true;
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
