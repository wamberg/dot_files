#!/usr/bin/env bash
# Map tinty theme to BAT_THEME for delta/bat

TINTY_CURRENT_SCHEME="$HOME/.local/share/tinted-theming/tinty/artifacts/current_scheme"

if [ -f "$TINTY_CURRENT_SCHEME" ]; then
  CURRENT_THEME=$(cat "$TINTY_CURRENT_SCHEME")

  # Map tinty theme names to delta/bat syntax themes
  # Order matters: more specific patterns must come first
  case "$CURRENT_THEME" in
    *dracula*)
      export BAT_THEME="Dracula"
      ;;
    *gruvbox*dark*)
      export BAT_THEME="gruvbox-dark"
      ;;
    *gruvbox*light*)
      export BAT_THEME="gruvbox-light"
      ;;
    *nord*light*)
      # Nord light doesn't have a delta equivalent, use generic light fallback
      export BAT_THEME="base16"
      ;;
    *nord*)
      # Only matches base16-nord (dark), not base16-nord-light
      export BAT_THEME="Nord"
      ;;
    *solarized*dark*)
      export BAT_THEME="Solarized (dark)"
      ;;
    *solarized*light*)
      export BAT_THEME="Solarized (light)"
      ;;
    *light*)
      # Generic light theme fallback
      export BAT_THEME="base16"
      ;;
    *)
      # Generic dark theme fallback
      export BAT_THEME="base16-256"
      ;;
  esac
fi
