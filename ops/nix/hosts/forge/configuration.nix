{ config, pkgs, ... }:

{
  imports = [ ./hardware-configuration.nix ];

  # Allow unfree packages (needed for proprietary software)
  nixpkgs.config.allowUnfree = true;

  # Bootloader - GRUB for dual-boot with Windows
  boot.loader.systemd-boot.enable = false;
  boot.loader.grub = {
    enable = true;
    device = "nodev";
    efiSupport = true;
    useOSProber = true;  # Detect Windows and other OSes
  };
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot";  # Not /boot/efi

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
    extraGroups = [ "wheel" "networkmanager" "video" "audio" ];
    # Password will be set during installation with nixos-install
  };

  # Enable sudo for wheel group
  security.sudo.wheelNeedsPassword = true;

  # Development tools (needed for nvim treesitter, mason, etc.)
  environment.systemPackages = with pkgs; [
    gcc
    gnumake
    pkg-config
    nodejs
    python3
    cargo
    rustc

    # Cursor theme for SDDM and system-wide
    adwaita-icon-theme
  ];

  # Desktop Environment - Niri Wayland Compositor
  programs.niri.enable = true;

  # Display Manager
  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
    theme = "breeze";  # Default theme with cursor support
  };

  # Audio - PipeWire
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    wireplumber.enable = true;
  };

  # Fonts
  fonts.packages = with pkgs; [
    jetbrains-mono
    font-awesome
    noto-fonts-color-emoji
    liberation_ttf
  ];

  # Hardware support
  hardware.bluetooth.enable = true;
  hardware.graphics.enable = true;
  hardware.graphics.enable32Bit = true;  # For 32-bit games

  # Boot - AMD microcode
  hardware.cpu.amd.updateMicrocode = true;

  # System services
  services.blueman.enable = true;  # Bluetooth manager
  services.udisks2.enable = true;  # Disk management
  services.gvfs.enable = true;     # Virtual filesystems

  # Gaming optimizations
  boot.kernel.sysctl = {
    "vm.max_map_count" = 2147483642;  # For games like Star Citizen, Elden Ring
  };

  # 32-bit libraries for Steam and gaming
  hardware.graphics.extraPackages32 = with pkgs.pkgsi686Linux; [
    mesa
  ];

  # Virtual camera support (for OBS virtual camera, etc.)
  boot.extraModulePackages = with config.boot.kernelPackages; [
    v4l2loopback
  ];
  boot.kernelModules = [ "v4l2loopback" "snd-usb-audio" ];
  boot.extraModprobeConfig = ''
    options v4l2loopback devices=1 video_nr=0 card_label="Virtual Camera" exclusive_caps=1
  '';

  # Polkit (authentication agent)
  security.polkit.enable = true;
  systemd.user.services.polkit-gnome-authentication-agent-1 = {
    description = "polkit-gnome-authentication-agent-1";
    wantedBy = [ "graphical-session.target" ];
    wants = [ "graphical-session.target" ];
    after = [ "graphical-session.target" ];
    serviceConfig = {
      Type = "simple";
      ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
      Restart = "on-failure";
      RestartSec = 1;
      TimeoutStopSec = 10;
    };
  };

  # 1Password - System-level config for polkit integration
  programs._1password.enable = true;
  programs._1password-gui = {
    enable = true;
    polkitPolicyOwners = [ "wamberg" ];
  };

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
