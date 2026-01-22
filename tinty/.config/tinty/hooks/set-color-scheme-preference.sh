#!/usr/bin/env bash
# Set system color-scheme preference based on current tinty theme variant

TINTY_CURRENT_SCHEME_FILE="$HOME/.local/share/tinted-theming/tinty/artifacts/current_scheme"

if [ -f "$TINTY_CURRENT_SCHEME_FILE" ]; then
    CURRENT_SCHEME=$(cat "$TINTY_CURRENT_SCHEME_FILE")
    SCHEMES_DIR="$HOME/.local/share/tinted-theming/tinty/repos/schemes"
    SCHEME_FILE=""

    # Find scheme file (base16 or base24)
    if [[ "$CURRENT_SCHEME" == base16-* ]]; then
        SCHEME_FILE="$SCHEMES_DIR/base16/${CURRENT_SCHEME#base16-}.yaml"
    elif [[ "$CURRENT_SCHEME" == base24-* ]]; then
        SCHEME_FILE="$SCHEMES_DIR/base24/${CURRENT_SCHEME#base24-}.yaml"
    fi

    if [ -n "$SCHEME_FILE" ] && [ -f "$SCHEME_FILE" ]; then
        # Extract variant field from YAML
        VARIANT=$(grep "^variant:" "$SCHEME_FILE" | awk '{print $2}' | tr -d '"')

        # Set color-scheme preferences for better app compatibility
        # freedesktop.org: 0 = no preference, 1 = prefer dark, 2 = prefer light
        # GNOME: "default" or "prefer-dark" or "prefer-light"
        ARTIFACTS_DIR="$HOME/.local/share/tinted-theming/tinty/artifacts"
        if [ "$VARIANT" = "dark" ]; then
            dconf write /org/freedesktop/appearance/color-scheme "uint32 1"
            dconf write /org/gnome/desktop/interface/color-scheme "'prefer-dark'"
            echo 'export COLORFGBG="15;0"' > "$ARTIFACTS_DIR/colorfgbg.sh"
        elif [ "$VARIANT" = "light" ]; then
            dconf write /org/freedesktop/appearance/color-scheme "uint32 2"
            dconf write /org/gnome/desktop/interface/color-scheme "'prefer-light'"
            echo 'export COLORFGBG="0;15"' > "$ARTIFACTS_DIR/colorfgbg.sh"
        fi
    fi
fi
