#!/usr/bin/env bash

# Check if virtual camera ffmpeg is running
is_running() {
    pgrep -f "ffmpeg.*mjpeg.*video_size 1280x720.*video1.*video0" > /dev/null
}

if [[ "$1" == "--status" ]]; then
    # Return JSON status for waybar
    if is_running; then
        echo '{"text": "● CAM", "tooltip": "Virtual Camera Active", "class": "recording"}'
    else
        echo '{"text": "", "tooltip": "", "class": "inactive"}'
    fi
    exit 0
fi

# Toggle functionality
if is_running; then
    # Kill the virtual camera
    pkill -f "ffmpeg.*mjpeg.*video_size 1280x720.*video1.*video0"
    notify-send "Virtual Camera" "Stopped" -t 2000
else
    # Start the virtual camera
    ffmpeg \
      -f v4l2 \
      -input_format mjpeg \
      -video_size 1280x720 \
      -framerate 30 \
      -i /dev/video1 \
      -c:v copy \
      -f v4l2 /dev/video0 &
    notify-send "Virtual Camera" "Started" -t 2000
fi
