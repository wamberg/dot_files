#!/usr/bin/env bash

# (Github Dark High Contrast) Colors for Tmux
# https://github.com/projekt0n/github-theme-contrib/blob/main/themes/tmux/github_dark_high_contrast.conf

set -g mode-style "fg=#f0f3f6,bg=#0a0c10"

set -g message-style "fg=#0a0c10,bg=#f0f3f6"
set -g message-command-style "fg=#0a0c10,bg=#f0f3f6"

set -g pane-border-style "fg=#f0f3f6"
set -g pane-active-border-style "fg=#71b7ff"

set -g status "on"
set -g status-justify "left"

set -g status-style "fg=#71b7ff,bg=#f0f3f6"

set -g status-left-length "100"
set -g status-right-length "100"

set -g status-left-style NONE
set -g status-right-style NONE

set -g status-left "#[fg=#f0f3f6,bg=#71b7ff,bold] #S #[fg=#71b7ff,bg=#f0f3f6,nobold,nounderscore,noitalics]"
set -g status-right "#[fg=#f0f3f6,bg=#f0f3f6,nobold,nounderscore,noitalics]#[fg=#f0f3f6,bg=#f0f3f6] #{prefix_highlight} #[fg=#babbbd,bg=#f0f3f6,nobold,nounderscore,noitalics]#[fg=#0a0c10,bg=#babbbd] %Y-%m-%d  %I:%M %p #[fg=#0366d6,bg=#babbbd,nobold,nounderscore,noitalics]#[fg=#f0f3f6,bg=#0366d6,bold] #h "

setw -g window-status-activity-style "underscore,fg=#9ea7b3,bg=#f0f3f6"
setw -g window-status-separator ""
setw -g window-status-style "NONE,fg=#ffffff,bg=#f0f3f6"
setw -g window-status-format "#[fg=#f0f3f6,bg=#f0f3f6,nobold,nounderscore,noitalics]#[fg=#454a51,bg=#f0f3f6,nobold,nounderscore,noitalics] #I  #W #F #[fg=#f0f3f6,bg=#f0f3f6,nobold,nounderscore,noitalics]"
setw -g window-status-current-format "#[fg=#f0f3f6,bg=#26cd4d,nobold,nounderscore,noitalics]#[fg=#0a0c10,bg=#26cd4d,bold] #I  #W #F #[fg=#26cd4d,bg=#f0f3f6,nobold,nounderscore,noitalics]"
