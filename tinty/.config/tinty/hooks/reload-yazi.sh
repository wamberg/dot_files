#!/usr/bin/env bash
# Reload yazi file manager with new theme by symlinking the appropriate flavor

TINTY_CURRENT_SCHEME_FILE="$HOME/.local/share/tinted-theming/tinty/artifacts/current_scheme"
YAZI_CONFIG_DIR="$HOME/.config/yazi"
YAZI_FLAVORS_DIR="$YAZI_CONFIG_DIR/flavors"
YAZI_THEME_FILE="$YAZI_CONFIG_DIR/theme.toml"
TINTY_YAZI_FLAVORS_REPO="$HOME/.local/share/tinted-theming/tinty/repos/yazi/flavors"

# Ensure directories exist
mkdir -p "$YAZI_FLAVORS_DIR"

# Read current scheme
if [ -f "$TINTY_CURRENT_SCHEME_FILE" ]; then
    CURRENT_SCHEME=$(cat "$TINTY_CURRENT_SCHEME_FILE")

    # Only process base16 schemes (yazi doesn't support base24)
    if [[ "$CURRENT_SCHEME" == base16-* ]]; then
        FLAVOR_DIR="$TINTY_YAZI_FLAVORS_REPO/${CURRENT_SCHEME}.yazi"

        if [ -d "$FLAVOR_DIR" ]; then
            # Remove existing symlink/directory for this theme if it exists
            rm -rf "$YAZI_FLAVORS_DIR/${CURRENT_SCHEME}.yazi"

            # Create symlink to the flavor
            ln -s "$FLAVOR_DIR" "$YAZI_FLAVORS_DIR/${CURRENT_SCHEME}.yazi"

            # Update theme.toml to use this flavor
            cat > "$YAZI_THEME_FILE" <<EOF
# Yazi theme configuration
# Theme managed by tinty (tinted-theming)
# https://yazi-rs.github.io/docs/configuration/theme

[flavor]
use = "$CURRENT_SCHEME"
EOF
        fi
    fi
fi
