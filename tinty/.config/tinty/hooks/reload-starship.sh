#!/usr/bin/env bash
# Reload starship with tinty colors (works with both base16 and base24)

TINTY_CURRENT_SCHEME_FILE="$HOME/.local/share/tinted-theming/tinty/artifacts/current_scheme"
STARSHIP_TEMPLATE="$HOME/.config/tinty/templates/starship/default.mustache"
STARSHIP_CONFIG="$HOME/.config/starship.toml"

if [ -f "$TINTY_CURRENT_SCHEME_FILE" ] && [ -f "$STARSHIP_TEMPLATE" ]; then
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
        # Extract colors from YAML
        BASE00=$(grep -E "^(  )?base00:" "$SCHEME_FILE" | awk '{print $2}' | tr -d '"#')
        BASE01=$(grep -E "^(  )?base01:" "$SCHEME_FILE" | awk '{print $2}' | tr -d '"#')
        BASE02=$(grep -E "^(  )?base02:" "$SCHEME_FILE" | awk '{print $2}' | tr -d '"#')
        BASE03=$(grep -E "^(  )?base03:" "$SCHEME_FILE" | awk '{print $2}' | tr -d '"#')
        BASE04=$(grep -E "^(  )?base04:" "$SCHEME_FILE" | awk '{print $2}' | tr -d '"#')
        BASE05=$(grep -E "^(  )?base05:" "$SCHEME_FILE" | awk '{print $2}' | tr -d '"#')
        BASE06=$(grep -E "^(  )?base06:" "$SCHEME_FILE" | awk '{print $2}' | tr -d '"#')
        BASE07=$(grep -E "^(  )?base07:" "$SCHEME_FILE" | awk '{print $2}' | tr -d '"#')
        BASE08=$(grep -E "^(  )?base08:" "$SCHEME_FILE" | awk '{print $2}' | tr -d '"#')
        BASE09=$(grep -E "^(  )?base09:" "$SCHEME_FILE" | awk '{print $2}' | tr -d '"#')
        BASE0A=$(grep -E "^(  )?base0A:" "$SCHEME_FILE" | awk '{print $2}' | tr -d '"#')
        BASE0B=$(grep -E "^(  )?base0B:" "$SCHEME_FILE" | awk '{print $2}' | tr -d '"#')
        BASE0C=$(grep -E "^(  )?base0C:" "$SCHEME_FILE" | awk '{print $2}' | tr -d '"#')
        BASE0D=$(grep -E "^(  )?base0D:" "$SCHEME_FILE" | awk '{print $2}' | tr -d '"#')
        BASE0E=$(grep -E "^(  )?base0E:" "$SCHEME_FILE" | awk '{print $2}' | tr -d '"#')
        BASE0F=$(grep -E "^(  )?base0F:" "$SCHEME_FILE" | awk '{print $2}' | tr -d '"#')
        SCHEME_NAME=$(grep "^name:" "$SCHEME_FILE" | sed 's/^name: *"\(.*\)"/\1/')
        SCHEME_AUTHOR=$(grep "^author:" "$SCHEME_FILE" | sed 's/^author: *"\(.*\)"/\1/')

        # Generate starship config from template
        sed -e "s|{{scheme-name}}|$SCHEME_NAME|g" \
            -e "s|{{scheme-author}}|$SCHEME_AUTHOR|g" \
            -e "s|{{base00-hex}}|$BASE00|g" \
            -e "s|{{base01-hex}}|$BASE01|g" \
            -e "s|{{base02-hex}}|$BASE02|g" \
            -e "s|{{base03-hex}}|$BASE03|g" \
            -e "s|{{base04-hex}}|$BASE04|g" \
            -e "s|{{base05-hex}}|$BASE05|g" \
            -e "s|{{base06-hex}}|$BASE06|g" \
            -e "s|{{base07-hex}}|$BASE07|g" \
            -e "s|{{base08-hex}}|$BASE08|g" \
            -e "s|{{base09-hex}}|$BASE09|g" \
            -e "s|{{base0A-hex}}|$BASE0A|g" \
            -e "s|{{base0B-hex}}|$BASE0B|g" \
            -e "s|{{base0C-hex}}|$BASE0C|g" \
            -e "s|{{base0D-hex}}|$BASE0D|g" \
            -e "s|{{base0E-hex}}|$BASE0E|g" \
            -e "s|{{base0F-hex}}|$BASE0F|g" \
            "$STARSHIP_TEMPLATE" > "$STARSHIP_CONFIG"
    fi
fi

# Starship automatically reloads config on each prompt, no explicit reload needed
