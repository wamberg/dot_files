#!/usr/bin/env bash

# Check if wf-recorder is running
is_running() {
    pgrep wf-recorder > /dev/null
}

if [[ "$1" == "--status" ]]; then
    # Return JSON status for waybar
    if is_running; then
        echo '{"text": "● D-REC", "tooltip": "Desktop Recording Active", "class": "recording"}'
    else
        echo '{"text": "", "tooltip": "", "class": "inactive"}'
    fi
    exit 0
fi

# Original toggle functionality
if is_running; then
    # Stop desktop recording
    killall wf-recorder
    notify-send "Recording" "Desktop recording stopped" -t 2000
else
    # Prompt for optional recording name
    recording_name=$(echo "" | fuzzel --dmenu --prompt "Recording name (optional): " --width 40) || exit 0

    # Build filename with optional suffix
    timestamp=$(date +%Y%m%d_%H%M%S)
    # Slugify: lowercase, replace spaces with hyphens, remove special chars
    slug=$(echo "$recording_name" | tr '[:upper:]' '[:lower:]' | tr ' ' '-' | tr -cd '[:alnum:]-')
    if [[ -n "$slug" ]]; then
        filename="${timestamp}_${slug}.mp4"
    else
        filename="${timestamp}.mp4"
    fi

    # Start desktop recording
    wf-recorder \
      --audio=@DEFAULT_SINK@.monitor \
      --audio=@DEFAULT_SOURCE@ \
      --codec=libx264 \
      --codec-param=crf=28 \
      --file="/home/wamberg/videos/${filename}" &
    notify-send "Recording" "Desktop recording started: ${filename}" -t 2000
fi
