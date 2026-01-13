{ config, pkgs, ... }:

let
  # Path to dotfiles repository
  dotfilesPath = "${config.home.homeDirectory}/dev/dot_files";

  # Path to nix-darwin flake
  nixPath = "${dotfilesPath}/ops/nix";

  # Darwin rebuild commands (equivalent to nbuild/ntest on NixOS)
  dbuild = pkgs.writeShellScriptBin "dbuild" ''
    cd ${nixPath} && \
    sudo $(which darwin-rebuild) switch --flake .#mac && \
    cd -
  '';

  dtest = pkgs.writeShellScriptBin "dtest" ''
    cd ${nixPath} && \
    darwin-rebuild check --flake .#mac && \
    cd -
  '';
in
{
  imports = [
    ../../common/home.nix
  ];

  # Host-specific packages for mac
  home.packages = with pkgs; [
    # Darwin management
    dbuild         # Rebuild and switch Darwin configuration
    dtest          # Test Darwin configuration

    # Development Tools
    claude-code    # Claude AI coding assistant CLI
    aider-chat     # AI pair programming tool

    # Terminal
    # Note: kitty works on macOS too
    kitty          # GPU-accelerated terminal

    # Core Applications (if managing through Nix instead of Homebrew)
    # firefox        # Firefox (macOS version)
    # obsidian       # Note-taking app

    # Add other cross-platform GUI apps here, or manage via Homebrew casks
  ];

  # Username and home directory
  home.username = "wamberg";
  home.homeDirectory = "/Users/wamberg";

  # 1Password SSH agent integration (macOS path)
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    matchBlocks = {
      "*" = {
        identityAgent = "~/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock";
      };
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

      # Packages to stow (subset of forge's list - no Wayland tools)
      packages=(
        aider
        bat
        bin
        claude
        git
        kitty
        mise
        mpv
        npm
        nvim
        sql
        tinty
        tmux
        vifm
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

  # Create tinty symlink for tinted-theming path (macOS-specific workaround)
  # Tinty expects config at ~/.config/tinted-theming/tinty/ but stow creates ~/.config/tinty/
  home.activation.setupTintySymlink = config.lib.dag.entryAfter ["stowDotfiles"] ''
    if [ -d "$HOME/.config/tinty" ] && [ ! -e "$HOME/.config/tinted-theming/tinty" ]; then
      echo "Creating tinty symlink for tinted-theming compatibility..."
      $DRY_RUN_CMD mkdir -p "$HOME/.config/tinted-theming"
      $DRY_RUN_CMD ln -sf "$HOME/.config/tinty" "$HOME/.config/tinted-theming/tinty"
    fi
  '';

  # Create supporting directories
  home.activation.createDirectories = config.lib.dag.entryAfter ["writeBoundary"] ''
    $DRY_RUN_CMD mkdir -p $HOME/.ssh
    $DRY_RUN_CMD mkdir -p $HOME/.tmux/plugins
    $DRY_RUN_CMD mkdir -p $HOME/videos
    $DRY_RUN_CMD mkdir -p $HOME/pics
    $DRY_RUN_CMD mkdir -p $HOME/docs
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
