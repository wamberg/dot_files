{ pkgs, unstablePkgs, ... }:

{
  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = "wamberg";
  home.homeDirectory = "/home/wamberg";

  imports = [ ./gnome-paperwm.nix ];

  home.packages = with pkgs; [
    (nerdfonts.override { fonts = [ "FiraCode" ]; })
    btop
    delta
    docker-compose
    fd
    ffmpeg
    firefox
    fzf
    gcc
    git
    git-crypt
    gnumake
    gnupg
    go_1_17
    google-chrome
    jq
    libreoffice
    mkcert
    neovim-nightly
    nodejs-16_x
    openssl
    pinentry_qt
    pipewire
    postman
    pre-commit
    pyright
    python310
    qt5.qtwayland
    ripgrep
    rsync
    shotcut
    stow
    tdesktop
    tmux
    tree
    unstable.kitty
    unstable.obs-studio
    unzip
    vifm
    wesnoth
    wget
    xclip
    yamllint
    zoom-us
    zsh
  ];

  services.gpg-agent = {
    enable = true;
    pinentryFlavor = "qt";
  };

  programs.direnv.enable = true;
  programs.direnv.nix-direnv.enable = true;
  # optional for nix flakes support in home-manager 21.11, not required in home-manager unstable or 22.05
  programs.direnv.nix-direnv.enableFlakes = true;

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
