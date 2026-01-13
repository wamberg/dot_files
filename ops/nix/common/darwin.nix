{ config, pkgs, ... }:

{
  # Enable flakes and nix-command
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Auto-optimize nix store
  nix.settings.auto-optimise-store = true;

  # Core system packages every host needs
  environment.systemPackages = with pkgs; [
    # Shell
    bash

    # Version control and editing
    git
    vim

    # Network utilities
    curl
    wget

    # File management
    rsync

    # System utilities
    less
  ];

  # Auto upgrade nix package and the daemon service
  services.nix-daemon.enable = true;

  # Used for backwards compatibility
  system.stateVersion = 5;
}
