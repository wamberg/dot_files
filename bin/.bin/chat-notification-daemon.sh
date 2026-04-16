#!/usr/bin/env bash

# Chat notification daemon - intercepts D-Bus notifications for chat apps
# and sets niri window urgency so waybar highlights the workspace

# Map of D-Bus app names to niri app_ids
declare -A APP_MAP=(
    ["Slack"]="slack"
    ["Telegram Desktop"]="org.telegram.desktop"
)

set_urgent() {
    local niri_app_id="$1"
    local window_id
    window_id=$(niri msg --json windows | jq -r --arg app "$niri_app_id" '.[] | select(.app_id == $app and .is_focused == false) | .id' | head -1)
    if [ -n "$window_id" ]; then
        niri msg action set-window-urgent --id "$window_id"
    fi
}

# Monitor D-Bus notifications
dbus-monitor --session "type='method_call',interface='org.freedesktop.Notifications',member='Notify'" | \
while read -r line; do
    if [[ "$line" == *"member=Notify"* ]]; then
        expecting_app_name=true
        continue
    fi

    if [[ "$expecting_app_name" == true && "$line" == *"string"* ]]; then
        app_name=$(echo "$line" | sed -n 's/.*string "\([^"]*\)".*/\1/p')
        expecting_app_name=false

        niri_app_id="${APP_MAP[$app_name]}"
        if [ -n "$niri_app_id" ]; then
            set_urgent "$niri_app_id"
        fi
    fi
done
