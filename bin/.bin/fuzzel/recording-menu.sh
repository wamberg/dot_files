#!/bin/bash

choice=$(echo -e "Virtual Camera Toggle\nRecord Desktop\nRecord Audio Only" | fuzzel --dmenu --prompt="Recording: ")

case "$choice" in
    "Virtual Camera Toggle")
        ~/dev/dot_files/bin/.bin/toggle-virtual-camera.sh
        ;;
    "Record Desktop")
        wf-recorder \
          --audio=@DEFAULT_SINK@.monitor \
          --audio=@DEFAULT_SOURCE@ \
          --codec=libx264 \
          --codec-param=crf=28 \
          --file=meeting_$(date +%Y%m%d_%H%M%S).mp4 &
        notify-send "Recording" "Desktop recording started" -t 2000
        ;;
    "Record Audio Only")
        ffmpeg \
          -f pulse -i @DEFAULT_SINK@.monitor \
          -f pulse -i @DEFAULT_SOURCE@ \
          -filter_complex "[0:a][1:a]amix=inputs=2[aout]" \
          -map "[aout]" \
          -c:a aac -b:a 128k \
          meeting_audio_$(date +%Y%m%d_%H%M%S).m4a &
        notify-send "Recording" "Audio recording started" -t 2000
        ;;
esac
