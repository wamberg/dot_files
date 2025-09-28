#!/bin/bash

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
    # Start desktop recording
    wf-recorder \
      --audio=@DEFAULT_SINK@.monitor \
      --audio=@DEFAULT_SOURCE@ \
      --codec=libx264 \
      --codec-param=crf=28 \
      --file=/home/wamberg/videos/$(date +%Y%m%d_%H%M%S).mp4 &
    notify-send "Recording" "Desktop recording started" -t 2000
fi
