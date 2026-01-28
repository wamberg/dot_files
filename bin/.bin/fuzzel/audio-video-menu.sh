#!/usr/bin/env bash

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
        HEADPHONES_SINK="alsa_output.usb-Focusrite_Scarlett_2i2_USB_Y8CZJFM0AA378C-00.HiFi__Line__sink"
        SPEAKERS_SINK="alsa_output.pci-0000_09_00.1.hdmi-stereo-extra4"
        SOUNDBAR_SINK="bluez_output.94_4F_4C_03_D5_4C.1"

        # Get current default sink
        CURRENT_SINK=$(pactl get-default-sink)

        # Check if soundbar is available
        soundbar_available=$(pactl list short sinks | grep -q "$SOUNDBAR_SINK" && echo "yes" || echo "no")

        # Toggle logic with soundbar preference
        if [ "$CURRENT_SINK" = "$HEADPHONES_SINK" ]; then
            # From headphones: prefer soundbar, fall back to speakers
            if [ "$soundbar_available" = "yes" ]; then
                pactl set-default-sink "$SOUNDBAR_SINK"
                notify-send "Audio Output" "Switched to Soundbar" -t 2000
            else
                pactl set-default-sink "$SPEAKERS_SINK"
                notify-send "Audio Output" "Switched to Speakers" -t 2000
            fi
        elif [ "$CURRENT_SINK" = "$SPEAKERS_SINK" ] || [ "$CURRENT_SINK" = "$SOUNDBAR_SINK" ]; then
            # From speakers or soundbar: go to headphones
            pactl set-default-sink "$HEADPHONES_SINK"
            notify-send "Audio Output" "Switched to Headphones" -t 2000
        else
            # Default to headphones if current sink is unknown
            pactl set-default-sink "$HEADPHONES_SINK"
            notify-send "Audio Output" "Switched to Headphones (default)" -t 2000
        fi
        ;;
esac
