#!/usr/bin/env bash
# Reload waybar with base16 fallback for base24 themes

TINTY_CURRENT_SCHEME_FILE="$HOME/.local/share/tinted-theming/tinty/artifacts/current_scheme"
WAYBAR_REPO_DIR="$HOME/.local/share/tinted-theming/tinty/repos/waybar/colors"
WAYBAR_ARTIFACT="$HOME/.local/share/tinted-theming/tinty/artifacts/waybar-colors-file.css"

if [ -f "$TINTY_CURRENT_SCHEME_FILE" ]; then
    CURRENT_SCHEME=$(cat "$TINTY_CURRENT_SCHEME_FILE")

    # If base24 theme, fall back to base16 equivalent
    if [[ "$CURRENT_SCHEME" == base24-* ]]; then
        FALLBACK_SCHEME="${CURRENT_SCHEME/base24-/base16-}"
        WAYBAR_THEME_FILE="$WAYBAR_REPO_DIR/${FALLBACK_SCHEME}.css"
    else
        WAYBAR_THEME_FILE="$WAYBAR_REPO_DIR/${CURRENT_SCHEME}.css"
    fi

    # Copy Waybar theme to artifacts directory if it exists
    if [ -f "$WAYBAR_THEME_FILE" ]; then
        cp "$WAYBAR_THEME_FILE" "$WAYBAR_ARTIFACT"
    fi
fi

# Send SIGUSR2 to reload waybar's CSS
if pgrep waybar >/dev/null 2>&1; then
    pkill -SIGUSR2 waybar
fi
