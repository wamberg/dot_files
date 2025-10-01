#!/bin/bash

choice=$(echo -e "Virtual Camera Toggle\nDesktop Recording Toggle\nAudio Recording Toggle\nSwitch Audio Output" | fuzzel --dmenu --prompt="A/V Menu: ")

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
    "Switch Audio Output")
        # Device mappings
        HEADPHONES_SINK="alsa_output.usb-Focusrite_Scarlett_2i2_USB_Y8CZJFM0AA378C-00.HiFi__Line1__sink"
        SPEAKERS_SINK="alsa_output.pci-0000_09_00.1.hdmi-stereo-extra4"
        
        # Get current default sink
        CURRENT_SINK=$(pactl get-default-sink)
        
        # Toggle to the other device
        if [ "$CURRENT_SINK" = "$HEADPHONES_SINK" ]; then
            pactl set-default-sink "$SPEAKERS_SINK"
            notify-send "Audio Output" "Switched to Speakers" -t 2000
        elif [ "$CURRENT_SINK" = "$SPEAKERS_SINK" ]; then
            pactl set-default-sink "$HEADPHONES_SINK"
            notify-send "Audio Output" "Switched to Headphones" -t 2000
        else
            # Default to headphones if current sink is unknown
            pactl set-default-sink "$HEADPHONES_SINK"
            notify-send "Audio Output" "Switched to Headphones (default)" -t 2000
        fi
        ;;
esac
