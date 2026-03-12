#!/usr/bin/env bash
# Generate mako config from tinty theme (matches starship pattern)

TINTY_CURRENT_SCHEME_FILE="$HOME/.local/share/tinted-theming/tinty/artifacts/current_scheme"
MAKO_TEMPLATE="$HOME/.config/tinty/templates/mako/default.mustache"
MAKO_CONFIG="$HOME/.config/mako/config"

if [ -f "$TINTY_CURRENT_SCHEME_FILE" ] && [ -f "$MAKO_TEMPLATE" ]; then
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
        BASE00=$(grep -E "^(  )?base00:" "$SCHEME_FILE" | awk '{print $2}' | tr -d '"#')
        BASE05=$(grep -E "^(  )?base05:" "$SCHEME_FILE" | awk '{print $2}' | tr -d '"#')
        BASE08=$(grep -E "^(  )?base08:" "$SCHEME_FILE" | awk '{print $2}' | tr -d '"#')
        BASE0A=$(grep -E "^(  )?base0A:" "$SCHEME_FILE" | awk '{print $2}' | tr -d '"#')
        BASE0D=$(grep -E "^(  )?base0D:" "$SCHEME_FILE" | awk '{print $2}' | tr -d '"#')
        SCHEME_NAME=$(grep "^name:" "$SCHEME_FILE" | sed 's/^name: *"\(.*\)"/\1/')
        SCHEME_AUTHOR=$(grep "^author:" "$SCHEME_FILE" | sed 's/^author: *"\(.*\)"/\1/')

        mkdir -p "$(dirname "$MAKO_CONFIG")"

        sed -e "s|{{scheme-name}}|$SCHEME_NAME|g" \
            -e "s|{{scheme-author}}|$SCHEME_AUTHOR|g" \
            -e "s|{{base00-hex}}|$BASE00|g" \
            -e "s|{{base05-hex}}|$BASE05|g" \
            -e "s|{{base08-hex}}|$BASE08|g" \
            -e "s|{{base0A-hex}}|$BASE0A|g" \
            -e "s|{{base0D-hex}}|$BASE0D|g" \
            "$MAKO_TEMPLATE" > "$MAKO_CONFIG"
    fi

    # Reload mako to apply new colors
    if pgrep mako >/dev/null 2>&1; then
        makoctl reload
    fi
fi
