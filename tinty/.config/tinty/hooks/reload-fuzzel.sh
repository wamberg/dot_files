#!/usr/bin/env bash
# Generate fuzzel config from tinty theme (matches starship pattern)

TINTY_CURRENT_SCHEME_FILE="$HOME/.local/share/tinted-theming/tinty/artifacts/current_scheme"
FUZZEL_TEMPLATE="$HOME/.config/tinty/templates/fuzzel/default.mustache"
FUZZEL_CONFIG="$HOME/.config/fuzzel/fuzzel.ini"

if [ -f "$TINTY_CURRENT_SCHEME_FILE" ] && [ -f "$FUZZEL_TEMPLATE" ]; then
    CURRENT_SCHEME=$(cat "$TINTY_CURRENT_SCHEME_FILE")

    # If base24 theme, fall back to base16 equivalent
    if [[ "$CURRENT_SCHEME" == base24-* ]]; then
        SCHEME_TO_USE="${CURRENT_SCHEME/base24-/base16-}"
    else
        SCHEME_TO_USE="$CURRENT_SCHEME"
    fi

    # Get colors from tinty scheme
    SCHEMES_DIR="$HOME/.local/share/tinted-theming/tinty/repos/schemes"
    SCHEME_FILE=""

    if [ -f "$SCHEMES_DIR/base16/${SCHEME_TO_USE#base16-}.yaml" ]; then
        SCHEME_FILE="$SCHEMES_DIR/base16/${SCHEME_TO_USE#base16-}.yaml"
    elif [ -f "$SCHEMES_DIR/base24/${SCHEME_TO_USE#base24-}.yaml" ]; then
        SCHEME_FILE="$SCHEMES_DIR/base24/${SCHEME_TO_USE#base24-}.yaml"
    fi

    if [ -n "$SCHEME_FILE" ] && [ -f "$SCHEME_FILE" ]; then
        BASE00=$(grep -E "^(  )?base00:" "$SCHEME_FILE" | awk '{print $2}' | tr -d '"#')
        BASE03=$(grep -E "^(  )?base03:" "$SCHEME_FILE" | awk '{print $2}' | tr -d '"#')
        BASE05=$(grep -E "^(  )?base05:" "$SCHEME_FILE" | awk '{print $2}' | tr -d '"#')
        BASE06=$(grep -E "^(  )?base06:" "$SCHEME_FILE" | awk '{print $2}' | tr -d '"#')
        BASE0D=$(grep -E "^(  )?base0D:" "$SCHEME_FILE" | awk '{print $2}' | tr -d '"#')
        SCHEME_NAME=$(grep "^name:" "$SCHEME_FILE" | sed 's/^name: *"\(.*\)"/\1/')
        SCHEME_AUTHOR=$(grep "^author:" "$SCHEME_FILE" | sed 's/^author: *"\(.*\)"/\1/')

        mkdir -p "$(dirname "$FUZZEL_CONFIG")"

        sed -e "s|{{scheme-name}}|$SCHEME_NAME|g" \
            -e "s|{{scheme-author}}|$SCHEME_AUTHOR|g" \
            -e "s|{{base00-hex}}|$BASE00|g" \
            -e "s|{{base03-hex}}|$BASE03|g" \
            -e "s|{{base05-hex}}|$BASE05|g" \
            -e "s|{{base06-hex}}|$BASE06|g" \
            -e "s|{{base0D-hex}}|$BASE0D|g" \
            "$FUZZEL_TEMPLATE" > "$FUZZEL_CONFIG"
    fi
fi
