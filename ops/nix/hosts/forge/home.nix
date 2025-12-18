{ config, pkgs, ... }:

let
  # Path to dotfiles repository (host-specific)
  dotfilesPath = "/mnt/shared";
in
{
  imports = [
    ../../common/home.nix
  ];

  # Host-specific packages for forge
  home.packages = with pkgs; [
    # Add forge-specific tools here as needed
  ];

  # Username and home directory
  home.username = "wamberg";
  home.homeDirectory = "/home/wamberg";

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
        glow
        kitty
        mako
        mise
        mpv
        niri
        npm
        nvim
        sql
        swappy
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
