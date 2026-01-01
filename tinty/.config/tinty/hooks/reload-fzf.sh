#!/usr/bin/env bash
# Reload FZF colors with base16 fallback for base24 themes

TINTY_CURRENT_SCHEME_FILE="$HOME/.local/share/tinted-theming/tinty/artifacts/current_scheme"
FZF_REPO_DIR="$HOME/.local/share/tinted-theming/tinty/repos/fzf/bash"
FZF_ARTIFACT="$HOME/.local/share/tinted-theming/tinty/artifacts/fzf-bash-file.config"

if [ -f "$TINTY_CURRENT_SCHEME_FILE" ]; then
    CURRENT_SCHEME=$(cat "$TINTY_CURRENT_SCHEME_FILE")

    # If base24 theme, fall back to base16 equivalent
    if [[ "$CURRENT_SCHEME" == base24-* ]]; then
        FALLBACK_SCHEME="${CURRENT_SCHEME/base24-/base16-}"
        FZF_THEME_FILE="$FZF_REPO_DIR/${FALLBACK_SCHEME}.config"
    else
        FZF_THEME_FILE="$FZF_REPO_DIR/${CURRENT_SCHEME}.config"
    fi

    # Copy FZF theme to artifacts directory if it exists
    if [ -f "$FZF_THEME_FILE" ]; then
        cp "$FZF_THEME_FILE" "$FZF_ARTIFACT"
    fi
fi
