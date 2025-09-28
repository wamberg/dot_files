#!/bin/bash

# Check if wf-recorder is running
if pgrep wf-recorder > /dev/null; then
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
