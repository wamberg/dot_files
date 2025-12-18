{ config, pkgs, ... }:

{
  imports = [ ./hardware-configuration.nix ];

  # Bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Shared folder
  fileSystems."/mnt/shared" = {
    device = "dot_files";
    fsType = "virtiofs";
  };

  # Hostname
  networking.hostName = "forge";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your timezone
  time.timeZone = "America/New_York";

  # Enable zsh
  programs.zsh.enable = true;

  # Define a user account
  users.users.wamberg = {
    isNormalUser = true;
    shell = pkgs.zsh;
    extraGroups = [ "wheel" "networkmanager" ];
    initialPassword = "changeme";
  };

  # Enable sudo for wheel group
  security.sudo.wheelNeedsPassword = true;

  # Services
  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "no";
    };
  };

  # Home-manager configuration
  home-manager.users.wamberg = import ./home.nix;

  system.stateVersion = "25.11";
}
