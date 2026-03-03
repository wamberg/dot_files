#!/usr/bin/env bash

PID_FILE="/tmp/audio_recording.pid"

# Check if audio recording ffmpeg is running
is_running() {
    [[ -f "$PID_FILE" ]] && kill -0 "$(cat "$PID_FILE")" 2>/dev/null
}

if [[ "$1" == "--status" ]]; then
    # Return JSON status for waybar
    if is_running; then
        echo '{"text": "● REC", "tooltip": "Audio Recording Active", "class": "recording"}'
    else
        echo '{"text": "", "tooltip": "", "class": "inactive"}'
    fi
    exit 0
fi

# Original toggle functionality
if is_running; then
    # Stop audio recording gracefully
    if [[ -f "$PID_FILE" ]]; then
        kill -TERM "$(cat "$PID_FILE")"
        sleep 2  # Allow time to flush buffers
        rm -f "$PID_FILE"
    fi
    notify-send "Recording" "Audio recording stopped" -t 2000
else
    # Prompt for optional recording name
    recording_name=$(echo "" | fuzzel --dmenu --prompt "Recording name (optional): " --width 40) || exit 0

    # Build filename with optional suffix
    timestamp=$(date +%Y%m%d_%H%M%S)
    # Slugify: lowercase, replace spaces with hyphens, remove special chars
    slug=$(echo "$recording_name" | tr '[:upper:]' '[:lower:]' | tr ' ' '-' | tr -cd '[:alnum:]-')
    if [[ -n "$slug" ]]; then
        filename="${timestamp}_${slug}.m4a"
    else
        filename="${timestamp}.m4a"
    fi

    # Start audio recording
    ffmpeg \
      -f pulse -i @DEFAULT_SINK@.monitor \
      -f pulse -i @DEFAULT_SOURCE@ \
      -filter_complex "[0:a][1:a]amix=inputs=2[aout]" \
      -map "[aout]" \
      -c:a aac -b:a 128k \
      "/home/wamberg/videos/${filename}" &

    # Store the PID for proper cleanup
    echo $! > "$PID_FILE"
    notify-send "Recording" "Audio recording started: ${filename}" -t 2000
fi
