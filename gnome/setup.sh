#!/bin/env bash

# This script customizes the gnome-shell with keyboard shortcuts and behaviors
# I prefer. It's safe to run multiple times.

# Custom Behaviors

gsettings set org.gnome.shell.app-switcher current-workspace-only true

# Custom Keybindings
dconf write /org/gnome/desktop/wm/keybindings/move-to-center "['<Super>c']"
dconf write /org/gnome/desktop/wm/keybindings/move-to-workspace-1 "['<Shift><Super>u']"
dconf write /org/gnome/desktop/wm/keybindings/move-to-workspace-2 "['<Shift><Super>i']"
dconf write /org/gnome/desktop/wm/keybindings/move-to-workspace-3 "['<Shift><Super>o']"
dconf write /org/gnome/desktop/wm/keybindings/move-to-workspace-4 "['<Shift><Super>p']"
dconf write /org/gnome/desktop/wm/keybindings/switch-to-workspace-1 "['<Super>u']"
dconf write /org/gnome/desktop/wm/keybindings/switch-to-workspace-2 "['<Super>i']"
dconf write /org/gnome/desktop/wm/keybindings/switch-to-workspace-3 "['<Super>o']"
dconf write /org/gnome/desktop/wm/keybindings/switch-to-workspace-4 "['<Super>p']"
dconf write /org/gnome/desktop/wm/keybindings/switch-to-workspace-last "['<Super>bracketleft']"
