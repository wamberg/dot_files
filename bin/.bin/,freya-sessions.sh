#!/usr/bin/env bash
set -e

# Bazaar session: single pane, runs eat-coach claude instance
tmux new-session -ds bazaar -c "$HOME/dev/bazaar"
tmux send-keys -t bazaar ",claude-switch.sh pbs-vanilla && claude --allow-dangerously-skip-permissions --dangerously-skip-permissions --plugin-dir $HOME/dev/bazaar/plugins/eat-coach --name $(date +%Y-%m-%d)-coach --remote-control" Enter

# Garden session: tns-style 3-pane layout, runs gardener claude instance
tmux new-session -ds garden -c "$HOME/dev/garden"
tmux rename-window -t garden:0 "code"
tmux split-window -bt garden:0 -l "25%" -c "$HOME/dev/garden"
tmux split-window -ht garden:0 -c "$HOME/dev/garden"
tmux select-pane -t 2
tmux send-keys -t garden:0.0 ",claude-switch.sh pbs-vanilla && claude --allow-dangerously-skip-permissions --dangerously-skip-permissions --plugin-dir $HOME/dev/bazaar/plugins/gardener --name $(date +%Y-%m-%d)-garden --remote-control" Enter
