#!/usr/bin/env bash
# Fuzzel-based wallpaper selector using swaybg

set -e

WALLPAPER_DIR="$HOME/pics/wallpaper"

# Get list of wallpaper images
get_wallpapers() {
    find "$WALLPAPER_DIR" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.webp" -o -iname "*.gif" \) -printf "%f\n" | sort
}

# Set wallpaper using swaybg
set_wallpaper() {
    local image="$1"
    local full_path="$WALLPAPER_DIR/$image"

    # Kill existing swaybg instance and start new one
    pkill swaybg || true
    swaybg -i "$full_path" &

    if command -v notify-send &> /dev/null; then
        notify-send "Wallpaper Set" "$image"
    fi
}

# Show wallpaper selection menu
show_menu() {
    local wallpapers=$(get_wallpapers)

    if [ -z "$wallpapers" ]; then
        notify-send "No Wallpapers" "No images found in $WALLPAPER_DIR"
        exit 1
    fi

    local selected=$(echo "$wallpapers" | fuzzel --dmenu --prompt="Wallpaper > ")

    if [ -n "$selected" ]; then
        set_wallpaper "$selected"
    fi
}

# Main entry point
show_menu
