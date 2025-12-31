#!/usr/bin/env bash
# Reload tmux configuration with new theme
if command -v tmux &> /dev/null; then
    tmux source-file ~/.tmux.conf 2>/dev/null || true
    for session in $(tmux list-sessions -F '#S' 2>/dev/null); do
        tmux refresh-client -S 2>/dev/null || true
    done
fi
