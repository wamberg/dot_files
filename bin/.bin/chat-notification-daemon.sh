#!/usr/bin/env bash

# Chat notification daemon - intercepts D-Bus notifications for chat apps
# and manages notification state for waybar

STATUS_DIR="/tmp/chat-notifications"
APPS=("Slack:slack" "Telegram Desktop:telegram")

# Ensure status directory exists
mkdir -p "$STATUS_DIR"

# Function to clear notification when app gains focus
clear_notification() {
    local app_id="$1"
    case "$app_id" in
        "Slack")
            rm -f "$STATUS_DIR/slack"
            ;;
        "org.telegram.desktop")
            rm -f "$STATUS_DIR/telegram"
            ;;
    esac
}

# Function to set notification when D-Bus notification received
set_notification() {
    local app_name="$1"
    case "$app_name" in
        "Slack")
            touch "$STATUS_DIR/slack"
            ;;
        "Telegram Desktop")
            touch "$STATUS_DIR/telegram"
            ;;
    esac
}

# Monitor niri window focus events to clear notifications
monitor_focus() {
    niri msg --json event-stream | while read -r event; do
        if echo "$event" | jq -e '.WindowFocusChanged' >/dev/null 2>&1; then
            # Extract window ID from the event
            window_id=$(echo "$event" | jq -r '.WindowFocusChanged.id')

            # Get all windows and find the one with matching ID
            app_id=$(niri msg --json windows | jq -r --arg id "$window_id" '.[] | select(.id == ($id | tonumber)) | .app_id // empty')

            if [ -n "$app_id" ]; then
                clear_notification "$app_id"
            fi
        fi
    done
}

# Monitor D-Bus notifications
monitor_notifications() {
    local expecting_app_name=false
    dbus-monitor --session "type='method_call',interface='org.freedesktop.Notifications',member='Notify'" | \
    while read -r line; do
        # Look for the Notify method call
        if [[ "$line" == *"member=Notify"* ]]; then
            expecting_app_name=true
            continue
        fi

        # If we're expecting the app name and this is a string line, extract it
        if [[ "$expecting_app_name" == true && "$line" == *"string"* ]]; then
            app_name=$(echo "$line" | sed -n 's/.*string "\([^"]*\)".*/\1/p')
            expecting_app_name=false

            for app_mapping in "${APPS[@]}"; do
                dbus_name="${app_mapping%:*}"
                if [[ "$app_name" == "$dbus_name" ]]; then
                    set_notification "$app_name"
                    break
                fi
            done
        fi
    done
}

# Start both monitors in background
monitor_focus &
monitor_notifications &

# Wait for both background processes
wait
