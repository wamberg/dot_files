#!/bin/bash

# Check if audio recording ffmpeg is running
if pgrep -f "ffmpeg.*pulse.*@DEFAULT_SINK@.*@DEFAULT_SOURCE@.*amix" > /dev/null; then
    # Stop audio recording
    pkill -f "ffmpeg.*pulse.*@DEFAULT_SINK@.*@DEFAULT_SOURCE@.*amix"
    notify-send "Recording" "Audio recording stopped" -t 2000
else
    # Start audio recording
    ffmpeg \
      -f pulse -i @DEFAULT_SINK@.monitor \
      -f pulse -i @DEFAULT_SOURCE@ \
      -filter_complex "[0:a][1:a]amix=inputs=2[aout]" \
      -map "[aout]" \
      -c:a aac -b:a 128k \
      /home/wamberg/videos/$(date +%Y%m%d_%H%M%S).m4a &
    notify-send "Recording" "Audio recording started" -t 2000
fi
