{ config, pkgs, ... }:

{
  # Enable flakes and nix-command
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Auto-optimize nix store (use nix.optimise.automatic instead of nix.settings.auto-optimise-store)
  nix.optimise.automatic = true;

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

  # Used for backwards compatibility
  system.stateVersion = 5;
}
