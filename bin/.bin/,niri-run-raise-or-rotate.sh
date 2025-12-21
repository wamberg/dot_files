#!/usr/bin/env bash

APP_ID=$1
shift
SPAWN_ARGS=("$@")

# If no spawn command is provided, default to the app_id.
if [ ${#SPAWN_ARGS[@]} -eq 0 ]; then
  SPAWN_ARGS=("$APP_ID")
fi

# Get IDs of all windows for the given application, sorted numerically.
mapfile -t WINDOW_IDS < <(niri msg -j windows | jq --arg app "$APP_ID" -r '.[] | select(.app_id == $app) | .id' | sort -n)

if ((${#WINDOW_IDS[@]} == 0)); then
    # If there are no instances of the app, launch it.
    niri msg action spawn -- "${SPAWN_ARGS[@]}"
    exit 0
fi

if ((${#WINDOW_IDS[@]} == 1)); then
    # If there is only one instance, focus it.
    niri msg action focus-window --id "${WINDOW_IDS[0]}"
    exit 0
fi

# If there are multiple instances, cycle focus.
FOCUSED_ID=$(niri msg -j focused-window | jq '.id')

current_index=-1
for i in "${!WINDOW_IDS[@]}"; do
    if [[ "${WINDOW_IDS[$i]}" == "$FOCUSED_ID" ]]; then
        current_index=$i
        break
    fi
done

if ((current_index == -1)); then
    # If no instance of this app is focused, focus the first one.
    niri msg action focus-window --id "${WINDOW_IDS[0]}"
else
    # Otherwise, focus the next one in the list (wrapping around).
    new_index=$(((current_index + 1) % ${#WINDOW_IDS[@]}))
    niri msg action focus-window --id "${WINDOW_IDS[$new_index]}"
fi
