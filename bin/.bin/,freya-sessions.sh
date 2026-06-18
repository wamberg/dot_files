#!/usr/bin/env bash
set -e

# Ensure WAYLAND_DISPLAY is set before creating the tmux server, so panes
# (and the claude instances they launch) can reach the Wayland compositor
# for wl-copy/wl-paste. Defense-in-depth alongside the graphical-session.target
# ordering in freya-sessions.service.
export WAYLAND_DISPLAY="${WAYLAND_DISPLAY:-$(systemctl --user show-environment | sed -n 's/^WAYLAND_DISPLAY=//p')}"

current_claude_profile=$(,claude-switch.sh --current 2>/dev/null || echo "pbs-sub")
,claude-switch.sh pbs-vanilla

# Bazaar session: single pane, runs eat-coach claude instance
tmux new-session -ds bazaar -c "$HOME/dev/bazaar" -x 200 -y 50
tmux send-keys -t bazaar "GARDEN_LOG_DISABLED=1 claude --allow-dangerously-skip-permissions --dangerously-skip-permissions --plugin-dir $HOME/dev/bazaar/plugins/eat-coach --name $(date +%Y-%m-%d)-coach --remote-control" Enter

# Garden session: tns-style 3-pane layout, runs gardener claude instance
tmux new-session -ds garden -c "$HOME/dev/garden" -x 200 -y 50
tmux send-keys -t garden "claude --allow-dangerously-skip-permissions --dangerously-skip-permissions --plugin-dir $HOME/dev/bazaar/plugins/gardener --name $(date +%Y-%m-%d)-garden --remote-control" Enter

sleep 3
,claude-switch.sh "$current_claude_profile"
