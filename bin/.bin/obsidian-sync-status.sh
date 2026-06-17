#!/bin/bash
# Waybar indicator for the headless Obsidian Sync daemon.
if [[ "${1:-}" == "--restart" ]]; then
  systemctl --user restart obsidian-sync.service
  exit 0
fi
state=$(systemctl --user is-active obsidian-sync.service 2>/dev/null)
# Plain Unicode only — the bar uses JetBrains Mono (no Nerd Font), matching the
# ● REC / ● CAM convention of the other custom modules.
case "$state" in
  active)     echo '{"text":"●🖋️","tooltip":"Obsidian Sync: running","class":"active"}' ;;
  activating) echo '{"text":"●🖋️","tooltip":"Obsidian Sync: reconnecting…","class":"activating"}' ;;
  *)          echo '{"text":"●🖋️ ✗","tooltip":"Obsidian Sync STOPPED — notes not syncing! Click to restart.","class":"failed"}' ;;
esac
