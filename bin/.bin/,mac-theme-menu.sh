#!/usr/bin/env bash
# fzf-based theme selector for tinty (macOS)
set -e

TINTY_CONFIG="$HOME/.config/tinty/config.toml"
FAVORITES_FILE="$HOME/.config/tinty/favorites.txt"
CURRENT_SCHEME_FILE="$HOME/.local/share/tinted-theming/tinty/artifacts/current_scheme"

CURRENT=""
if [ -f "$CURRENT_SCHEME_FILE" ]; then
    CURRENT=$(cat "$CURRENT_SCHEME_FILE")
fi

# Show favorites first (starred), then all themes
{
    if [ -f "$FAVORITES_FILE" ] && [ -s "$FAVORITES_FILE" ]; then
        sed 's/^/* /' "$FAVORITES_FILE"
    fi
    tinty -c "$TINTY_CONFIG" list | awk '{print $1}'
} | fzf --prompt="theme ($CURRENT)> " | sed 's/^\* //' | xargs -r tinty -c "$TINTY_CONFIG" apply
