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
      # Example macOS apps you might want:
      # "1password"
      # "docker"
      # "iterm2"
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
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;
}
