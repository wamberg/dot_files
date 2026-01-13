{ config, pkgs, ... }:

{
  # Import common Darwin configuration
  imports = [
    ../../common/darwin.nix
  ];

  # System-wide packages for mac
  environment.systemPackages = with pkgs; [
    # macOS-specific system tools can go here
  ];

  # Default shell
  programs.zsh.enable = true;
  environment.shells = [ pkgs.zsh ];

  # Define user account (required for home-manager on Darwin)
  users.users.wamberg = {
    name = "wamberg";
    home = "/Users/wamberg";
  };

  # Set primary user (required for homebrew and other user-specific features)
  system.primaryUser = "wamberg";

  # Homebrew integration (for macOS GUI apps)
  # This allows declarative management of Mac App Store apps and casks
  homebrew = {
    enable = true;

    # Automatically update Homebrew
    onActivation = {
      autoUpdate = true;
      upgrade = true;
      cleanup = "zap";  # Uninstall packages not in config
    };

    # Mac App Store apps (use `mas search <app>` to find IDs)
    masApps = {
      # Example: "Xcode" = 497799835;
    };

    # Homebrew casks (GUI applications)
    casks = [
      "1password"      # 1Password GUI
      "1password-cli"  # 1Password CLI (op command)
    ];

    # Homebrew taps (third-party repositories)
    taps = [];

    # Regular Homebrew packages (formulae)
    brews = [];
  };

  # Home-manager integration
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    users.wamberg = import ./home.nix;
    # Backup conflicting files with .backup extension
    backupFileExtension = "backup";
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;
}
