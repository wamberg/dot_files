{ config, pkgs, ... }:

let
  # Path to dotfiles repository
  dotfilesPath = "/home/wamberg/dev/dot_files";

  # Path to NixOS flake
  nixPath = "${dotfilesPath}/ops/nix";

  # NixOS rebuild commands
  nbuild = pkgs.writeShellScriptBin "nbuild" ''
    cd ${nixPath} && \
    sudo nixos-rebuild switch --flake .#forge && \
    cd -
  '';

  ntest = pkgs.writeShellScriptBin "ntest" ''
    cd ${nixPath} && \
    sudo nixos-rebuild test --flake .#forge && \
    cd -
  '';
in
{
  imports = [
    ../../common/home.nix
  ];

  # Allow unfree packages in home-manager
  nixpkgs.config.allowUnfree = true;

  # Host-specific packages for forge
  home.packages = with pkgs; [
    # NixOS management
    nbuild         # Rebuild and switch NixOS configuration
    ntest          # Test NixOS configuration without switching

    # AMD GPU support (forge has AMD GPU)
    (btop.override { rocmSupport = true; })
    libva-utils    # VAAPI diagnostics (vainfo command)

    # Media tools
    feh            # Image viewer
    ffmpeg-full    # Video/audio converter with all codecs
    jellyfin-media-player  # Jellyfin desktop client
    pngquant       # PNG image optimization
    v4l-utils      # Video4Linux utilities (v4l2-ctl)
    wl-clipboard   # Wayland clipboard (wl-copy/wl-paste)
    zathura        # PDF viewer

    # Desktop Environment Tools
    bemoji         # Emoji search
    fuzzel         # Application launcher
    grim           # Screenshot tool
    mako           # Notification daemon
    slurp          # Screen area selector
    swappy         # Screenshot editor
    swaybg         # Wallpaper setter
    swaylock       # Screen locker
    tz             # Time zone viewer
    waybar         # Status bar
    wf-recorder    # Screen recorder
    wlsunset       # Color temperature adjuster
    xwayland-satellite  # Xwayland integration

    # Terminal
    kitty          # GPU-accelerated terminal

    # Audio
    pavucontrol    # PulseAudio/PipeWire volume control
    pulseaudio     # PulseAudio tools (pactl)
    whisper-cpp-vulkan  # speech-to-text

    # System Utilities
    blueman        # Bluetooth manager GUI

    # Cursor theme
    adwaita-icon-theme  # Includes default cursor theme

    # Development Tools
    aider-chat     # AI pair programming tool
    beads          # Issue tracker for AI agents
    claude-code    # Claude AI coding assistant CLI
    direnv         # Shell Env Management

    # Core Applications
    firefox-devedition  # Firefox Developer Edition
    google-chrome  # Chrome browser
    mpv            # Video player
    obsidian       # Note-taking app

    # Communication
    discord        # Discord client
    iamb           # Matrix chat client (terminal)
    slack          # Slack client
    telegram-desktop  # Telegram client

    # Productivity
    calibre        # E-book manager
    libreoffice-fresh  # Office suite

    # Gaming
    steam          # Steam client

    # Other
    zoom-us        # Video conferencing
  ];

  # Username and home directory
  home.username = "wamberg";
  home.homeDirectory = "/home/wamberg";

  # 1Password SSH agent integration (system-level GUI/CLI config in configuration.nix)
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;  # Disable default values (future-proofing)
    matchBlocks = {
      "*" = {
        identityAgent = "~/.1password/agent.sock";
      };
    };
  };

  # Cursor theme
  home.pointerCursor = {
    name = "Adwaita";
    package = pkgs.adwaita-icon-theme;
    size = 24;
    gtk.enable = true;
  };

  # Default applications
  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "application/pdf" = "org.pwmt.zathura.desktop";

      # Browser (URLs)
      "x-scheme-handler/http" = "firefox-devedition.desktop";
      "x-scheme-handler/https" = "firefox-devedition.desktop";
      "text/html" = "firefox-devedition.desktop";
      "application/xhtml+xml" = "firefox-devedition.desktop";

      # Images
      "image/jpeg" = "feh.desktop";
      "image/png" = "feh.desktop";
      "image/gif" = "feh.desktop";

      # Video
      "video/mp4" = "mpv.desktop";
      "video/x-matroska" = "mpv.desktop";

      # Audio
      "audio/mpeg" = "mpv.desktop";
      "audio/flac" = "mpv.desktop";
    };
  };

  # Install oh-my-zsh (framework only, .zshrc managed by stow)
  home.activation.installOhMyZsh = config.lib.dag.entryAfter ["writeBoundary"] ''
    if [ ! -d "$HOME/.oh-my-zsh/.git" ]; then
      echo "Installing oh-my-zsh..."
      $DRY_RUN_CMD ${pkgs.git}/bin/git clone https://github.com/ohmyzsh/ohmyzsh.git $HOME/.oh-my-zsh --depth 1
    fi
  '';

  # Stow dotfiles on activation
  home.activation.stowDotfiles = config.lib.dag.entryAfter ["writeBoundary"] ''
    if [ -d ${dotfilesPath} ]; then
      echo "Stowing dotfiles from ${dotfilesPath}..."

      # Packages to stow
      packages=(
        aider
        bat
        bin
        claude
        fuzzel
        git
        iamb
        kitty
        mako
        mise
        mpv
        niri
        npm
        nvim
        sql
        swappy
        tinty
        tmux
        vifm
        waybar
        zsh
      )

      for package in "''${packages[@]}"; do
        if [ -d "${dotfilesPath}/$package" ]; then
          $DRY_RUN_CMD ${pkgs.stow}/bin/stow \
            --dir=${dotfilesPath} \
            --target=$HOME \
            --restow \
            --no-folding \
            --verbose=1 \
            $package || true
        fi
      done
    else
      echo "Warning: ${dotfilesPath} not found, skipping dotfiles stow"
    fi
  '';

  # Create supporting directories
  home.activation.createDirectories = config.lib.dag.entryAfter ["writeBoundary"] ''
    $DRY_RUN_CMD mkdir -p $HOME/.ssh
    $DRY_RUN_CMD mkdir -p $HOME/.tmux/plugins
    $DRY_RUN_CMD mkdir -p $HOME/videos
    $DRY_RUN_CMD mkdir -p $HOME/pics/wallpaper
    $DRY_RUN_CMD mkdir -p $HOME/docs/calibre
    $DRY_RUN_CMD mkdir -p $HOME/dev

    # Set .ssh permissions
    $DRY_RUN_CMD chmod 700 $HOME/.ssh
  '';

  # Clone tmux plugin manager (tpm) if not present
  home.activation.installTpm = config.lib.dag.entryAfter ["createDirectories"] ''
    if [ ! -d "$HOME/.tmux/plugins/tpm/.git" ]; then
      echo "Installing tmux plugin manager (tpm)..."
      $DRY_RUN_CMD ${pkgs.git}/bin/git clone https://github.com/tmux-plugins/tpm $HOME/.tmux/plugins/tpm --depth 1
    fi
  '';
}
