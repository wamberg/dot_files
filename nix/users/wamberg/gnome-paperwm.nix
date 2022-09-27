{ config, lib, pkgs, ... }:

{
  home.packages = with pkgs; [
    flameshot # Fancy screenshot tool
    gnome.gnome-tweaks
    gnomeExtensions.disable-workspace-switch-animation-for-gnome-40
    gnome42Extensions.paperwm # The best tiling window manager
    gnomeExtensions.run-or-raise
    wmctrl # Used to "focus or launch" apps
  ];

  dconf.settings = {

    "org/gnome/shell" = {
      enabled-extensions = [
        "instantworkspaceswitcher@amalantony.net" # fix some UI glitches gnome40+paperwm
        "paperwm@hedning:matrix.org" # paperwm - best scrolling WM there is
        "run-or-raise@edvard.cz"
      ];
    };

    "org/gnome/desktop/interface" = { clock-format = "12h"; };

    "org/gnome/shell/extensions/paperwm" = {
      horizontal-margin = 0;
      vertical-margin = 0;
      vertical-margin-bottom = 0;
      window-gap = 0;
    };

    "org/gnome/shell/extensions/paperwm/keybindings" = {
      center-horizontally = [ "<Super>c" ];
      take-window = [ ]; # Free <Super>t
      toggle-scratch = [ "<Super>s" ]; # Attach/detach window to scratch layer
      toggle-scratch-layer =
        [ "<Super><Shift>s" ]; # Toggles the floating scratch layer
    };

    "org/gnome/shell/extensions/paperwm/workspaces" = {
      list = [ "home" "media" ];
    };

    "org/gnome/shell/extensions/paperwm/workspaces/home" = {
      index = 0;
      name = "Home";
    };

    "org/gnome/shell/extensions/paperwm/workspaces/media" = {
      index = 1;
      name = "Media";
    };

    # map the mappings
    "org/gnome/settings-daemon/plugins/media-keys" = {

      # Unset default screenshot key, so I can rebind to flameshot
      screenshot = [ ];
      volume-down = [ "<Super>bracketleft" ];
      volume-up = [ "<Super>bracketright" ];

      custom-keybindings = [
        # custom bindings 9x - misc
        "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom91/"
      ];
    };

    # custom bindings 9x - misc
    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom91" =
      {
        binding = "Print";
        command = "flameshot gui --delay=200";
        name = "flameshot screenshot";
      };
  };
}
