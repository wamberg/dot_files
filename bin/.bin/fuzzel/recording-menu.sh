#!/bin/bash

choice=$(echo -e "Virtual Camera Toggle\nDesktop Recording Toggle\nAudio Recording Toggle" | fuzzel --dmenu --prompt="Recording: ")

case "$choice" in
    "Virtual Camera Toggle")
        ~/dev/dot_files/bin/.bin/fuzzel/toggle-virtual-camera.sh
        ;;
    "Desktop Recording Toggle")
        ~/dev/dot_files/bin/.bin/fuzzel/toggle-desktop-recording.sh
        ;;
    "Audio Recording Toggle")
        ~/dev/dot_files/bin/.bin/fuzzel/toggle-audio-recording.sh
        ;;
esac
