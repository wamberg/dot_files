#!/usr/bin/env bash
# Map tinty theme to BAT_THEME for delta/bat

# Source shared library
source "$HOME/.config/tinty/scripts/lib.sh"

TINTY_CURRENT_SCHEME="$HOME/.local/share/tinted-theming/tinty/artifacts/current_scheme"

if [ -f "$TINTY_CURRENT_SCHEME" ]; then
  CURRENT_THEME=$(cat "$TINTY_CURRENT_SCHEME")
  export BAT_THEME=$(get_bat_theme_for_scheme "$CURRENT_THEME")
fi
