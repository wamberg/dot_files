#!/usr/bin/env bash
# Reload vifm with tinty colors (works with both base16 and base24)

TINTY_CURRENT_SCHEME_FILE="$HOME/.local/share/tinted-theming/tinty/artifacts/current_scheme"
VIFM_TEMPLATE="$HOME/.config/tinty/templates/vifm/default.mustache"
VIFM_COLORS_DIR="$HOME/.config/vifm/colors"
VIFM_RC="$HOME/.config/vifm/vifmrc"

# Ensure colors directory exists
mkdir -p "$VIFM_COLORS_DIR"

if [ -f "$TINTY_CURRENT_SCHEME_FILE" ] && [ -f "$VIFM_TEMPLATE" ]; then
    CURRENT_SCHEME=$(cat "$TINTY_CURRENT_SCHEME_FILE")

    # Get scheme file (base16 or base24)
    SCHEMES_DIR="$HOME/.local/share/tinted-theming/tinty/repos/schemes"
    SCHEME_FILE=""

    if [[ "$CURRENT_SCHEME" == base16-* ]]; then
        SCHEME_FILE="$SCHEMES_DIR/base16/${CURRENT_SCHEME#base16-}.yaml"
    elif [[ "$CURRENT_SCHEME" == base24-* ]]; then
        SCHEME_FILE="$SCHEMES_DIR/base24/${CURRENT_SCHEME#base24-}.yaml"
    fi

    if [ -n "$SCHEME_FILE" ] && [ -f "$SCHEME_FILE" ]; then
        # Extract metadata from YAML
        SCHEME_NAME=$(grep "^name:" "$SCHEME_FILE" | sed 's/^name: *"\(.*\)"/\1/')
        SCHEME_AUTHOR=$(grep "^author:" "$SCHEME_FILE" | sed 's/^author: *"\(.*\)"/\1/')

        # Generate vifm color file from template
        # Base24 schemes contain all base16 colors, so template works for both
        sed -e "s|{{scheme-name}}|$SCHEME_NAME|g" \
            -e "s|{{scheme-author}}|$SCHEME_AUTHOR|g" \
            "$VIFM_TEMPLATE" > "$VIFM_COLORS_DIR/tinty.vifm"

        # Update vifmrc to use tinty colorscheme if not already set
        if ! grep -q "^colorscheme tinty" "$VIFM_RC" 2>/dev/null; then
            # Replace existing colorscheme line or add new one
            if grep -q "^colorscheme" "$VIFM_RC" 2>/dev/null; then
                sed -i 's/^colorscheme.*/colorscheme tinty/' "$VIFM_RC"
            else
                echo "colorscheme tinty" >> "$VIFM_RC"
            fi
        fi
    fi
fi
