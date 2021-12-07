{ pkgs, unstablePkgs, ... }:

{
  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = "wamberg";
  home.homeDirectory = "/home/wamberg";

  home.packages = with pkgs; [
    (nerdfonts.override { fonts = [ "FiraCode" ]; })
    delta
    firefox
    fzf
    gcc
    git
    git-crypt
    gnome.gnome-tweaks
    gnumake
    gnupg
    google-chrome
    neovim-nightly
    nodejs-16_x
    obs-studio
    pinentry_qt
    python310
    ripgrep
    rsync
    stow
    tdesktop
    tree
    tmux
    unzip
    wget
    zoom-us
    zsh
  ];

  services.gpg-agent = {
    enable = true;
    pinentryFlavor = "qt";

  };

  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "21.11";
}
