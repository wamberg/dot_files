#!/usr/bin/env bash

# Check notification status for chat applications
# Usage: chat-notification-status.sh [app_name]

APP="${1:-all}"
STATUS_DIR="/tmp/chat-notifications"

# Icon paths
TELEGRAM_ICON="/usr/share/icons/hicolor/64x64/apps/org.telegram.desktop.png"
SLACK_ICON="/usr/share/pixmaps/slack.png"

# Ensure status directory exists
mkdir -p "$STATUS_DIR"

case "$APP" in
    "slack")
        if [ -f "$STATUS_DIR/slack" ]; then
            echo '{"text": " ", "class": "unread"}'
        else
            echo '{"text": "", "class": "hidden"}'
        fi
        ;;
    "telegram")
        if [ -f "$STATUS_DIR/telegram" ]; then
            echo '{"text": " ", "class": "unread"}'
        else
            echo '{"text": "", "class": "hidden"}'
        fi
        ;;
    "all")
        slack_icon=""
        telegram_icon=""

        [ -f "$STATUS_DIR/slack" ] && slack_icon=" "
        [ -f "$STATUS_DIR/telegram" ] && telegram_icon=" "

        echo "slack:$slack_icon telegram:$telegram_icon"
        ;;
    *)
        echo "Usage: $0 [slack|telegram|all]"
        exit 1
        ;;
esac
