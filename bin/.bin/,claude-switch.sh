#!/usr/bin/env bash
set -e

PROFILES_DIR="$HOME/dev/dot_files/claude-code-cli/profiles"
TARGET="$HOME/.claude/settings.json"

# List available profiles
profiles=()
for dir in "$PROFILES_DIR"/*/; do
    [ -f "$dir/settings.json" ] && profiles+=("$(basename "$dir")")
done

if [ ${#profiles[@]} -eq 0 ]; then
    echo "No profiles found in $PROFILES_DIR" >&2
    exit 1
fi

# Show current profile
if [ "$1" = "--current" ]; then
    if [ -L "$TARGET" ]; then
        basename "$(dirname "$(readlink "$TARGET")")"
    else
        echo "No profile set (settings.json is not a symlink)" >&2
        exit 1
    fi
    exit 0
fi

# Select profile: use argument or fzf
if [ -n "$1" ]; then
    profile="$1"
    # Validate the argument is a known profile
    found=false
    for p in "${profiles[@]}"; do
        [ "$p" = "$profile" ] && found=true && break
    done
    if [ "$found" = false ]; then
        echo "Unknown profile: $profile" >&2
        echo "Available: ${profiles[*]}" >&2
        exit 1
    fi
else
    profile=$(printf '%s\n' "${profiles[@]}" | fzf --prompt="Claude profile: ")
    [ -z "$profile" ] && exit 0
fi

source="$PROFILES_DIR/$profile/settings.json"
ln -sf "$source" "$TARGET"
echo "Switched to $profile"
