#!/usr/bin/env bash
# Reload FZF colors with tinty colors (works with both base16 and base24)

TINTY_CURRENT_SCHEME_FILE="$HOME/.local/share/tinted-theming/tinty/artifacts/current_scheme"
FZF_TEMPLATE="$HOME/.config/tinty/templates/fzf/default.mustache"
FZF_ARTIFACT="$HOME/.local/share/tinted-theming/tinty/artifacts/fzf-bash-file.config"

if [ -f "$TINTY_CURRENT_SCHEME_FILE" ] && [ -f "$FZF_TEMPLATE" ]; then
    CURRENT_SCHEME=$(cat "$TINTY_CURRENT_SCHEME_FILE")

    # Get scheme file (base16 or base24)
    SCHEMES_DIR="$HOME/.local/share/tinted-theming/tinty/repos/schemes"
    SCHEME_FILE=""

    if [[ "$CURRENT_SCHEME" == base16-* ]]; then
        SCHEME_FILE="$SCHEMES_DIR/base16/${CURRENT_SCHEME#base16-}.yaml"
        SCHEME_SYSTEM="base16"
    elif [[ "$CURRENT_SCHEME" == base24-* ]]; then
        SCHEME_FILE="$SCHEMES_DIR/base24/${CURRENT_SCHEME#base24-}.yaml"
        SCHEME_SYSTEM="base24"
    fi

    if [ -n "$SCHEME_FILE" ] && [ -f "$SCHEME_FILE" ]; then
        # Extract colors and metadata from YAML (handles both old and new format)
        BASE00=$(grep -E "^(  )?base00:" "$SCHEME_FILE" | awk '{print $2}' | tr -d '"#')
        BASE01=$(grep -E "^(  )?base01:" "$SCHEME_FILE" | awk '{print $2}' | tr -d '"#')
        BASE04=$(grep -E "^(  )?base04:" "$SCHEME_FILE" | awk '{print $2}' | tr -d '"#')
        BASE06=$(grep -E "^(  )?base06:" "$SCHEME_FILE" | awk '{print $2}' | tr -d '"#')
        BASE0A=$(grep -E "^(  )?base0A:" "$SCHEME_FILE" | awk '{print $2}' | tr -d '"#')
        BASE0C=$(grep -E "^(  )?base0C:" "$SCHEME_FILE" | awk '{print $2}' | tr -d '"#')
        BASE0D=$(grep -E "^(  )?base0D:" "$SCHEME_FILE" | awk '{print $2}' | tr -d '"#')
        SCHEME_NAME=$(grep "^name:" "$SCHEME_FILE" | sed 's/^name: *"\(.*\)"/\1/')
        SCHEME_AUTHOR=$(grep "^author:" "$SCHEME_FILE" | sed 's/^author: *"\(.*\)"/\1/')

        # Generate FZF config from template (using | as delimiter to handle / in author names)
        sed -e "s|{{scheme-name}}|$SCHEME_NAME|g" \
            -e "s|{{scheme-system}}|$SCHEME_SYSTEM|g" \
            -e "s|{{scheme-author}}|$SCHEME_AUTHOR|g" \
            -e "s|{{base00-hex}}|$BASE00|g" \
            -e "s|{{base01-hex}}|$BASE01|g" \
            -e "s|{{base04-hex}}|$BASE04|g" \
            -e "s|{{base06-hex}}|$BASE06|g" \
            -e "s|{{base0A-hex}}|$BASE0A|g" \
            -e "s|{{base0C-hex}}|$BASE0C|g" \
            -e "s|{{base0D-hex}}|$BASE0D|g" \
            "$FZF_TEMPLATE" > "$FZF_ARTIFACT"
    fi
fi
