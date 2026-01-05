#!/usr/bin/env bash
# Shared functions for tinty theme management

# Map tinty theme name to corresponding bat/delta syntax theme
# Usage: get_bat_theme_for_scheme "base16-dracula"
# Returns: bat theme name (e.g., "Dracula", "gruvbox-dark", etc.)
get_bat_theme_for_scheme() {
    local scheme="$1"

    if [ -z "$scheme" ]; then
        echo "not set"
        return
    fi

    # Map tinty theme names to bat syntax themes
    # Order matters: more specific patterns must come first
    case "$scheme" in
        *dracula*)
            echo "Dracula"
            ;;
        *gruvbox*dark*)
            echo "gruvbox-dark"
            ;;
        *gruvbox*light*)
            echo "gruvbox-light"
            ;;
        base16-github|base24-github)
            # GitHub light themes (not -dark variants)
            echo "GitHub"
            ;;
        *nord*light*)
            # Nord light doesn't have a delta equivalent, use generic light fallback
            echo "base16"
            ;;
        *nord*)
            # Only matches base16-nord (dark), not base16-nord-light
            echo "Nord"
            ;;
        *solarized*dark*)
            echo "Solarized (dark)"
            ;;
        *solarized*light*)
            echo "Solarized (light)"
            ;;
        *light*)
            # Generic light theme fallback
            echo "base16"
            ;;
        *)
            # Generic dark theme fallback
            echo "base16-256"
            ;;
    esac
}
