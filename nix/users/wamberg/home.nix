{ pkgs, unstablePkgs, ... }:

{
  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = "wamberg";
  home.homeDirectory = "/home/wamberg";

  imports = [
    ./gnome-paperwm.nix
  ];

  home.packages = with pkgs; [
    (nerdfonts.override { fonts = [ "FiraCode" ]; })
    delta
    docker-compose
    ffmpeg
    firefox
    fzf
    gcc
    git
    git-crypt
    glow
    gnumake
    gnupg
    go_1_17
    google-chrome
    jo
    jq
    libreoffice
    mkcert
    neovim-nightly
    nodejs-16_x
    openssl
    pinentry_qt
    pipewire
    pre-commit
    python310
    qt5.qtwayland
    ripgrep
    rsync
    stow
    tdesktop
    tmux
    tree
    universal-ctags
    unstable.alacritty
    unstable.obs-studio
    unzip
    vifm
    wget
    yamllint
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
