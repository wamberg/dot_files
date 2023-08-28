#!/usr/bin/env bash

# (Github Light High Contrast) Colors for Tmux
# https://github.com/projekt0n/github-theme-contrib/blob/main/themes/tmux/github_light_high_contrast.conf

set -g mode-style "fg=#010409,bg=#ffffff"

set -g message-style "fg=#ffffff,bg=#010409"
set -g message-command-style "fg=#ffffff,bg=#010409"

set -g pane-border-style "fg=#010409"
set -g pane-active-border-style "fg=#0349b4"

set -g status "on"
set -g status-justify "left"

set -g status-style "fg=#0349b4,bg=#010409"

set -g status-left-length "100"
set -g status-right-length "100"

set -g status-left-style NONE
set -g status-right-style NONE

set -g status-left "#[fg=#010409,bg=#0349b4,bold] #S #[fg=#0349b4,bg=#010409,nobold,nounderscore,noitalics]"
set -g status-right "#[fg=#010409,bg=#010409,nobold,nounderscore,noitalics]#[fg=#010409,bg=#010409] #{prefix_highlight} #[fg=#0366d6,bg=#010409,nobold,nounderscore,noitalics]#[fg=#010409,bg=#0366d6,bold] #h "

setw -g window-status-activity-style "underscore,fg=#66707b,bg=#010409"
setw -g window-status-separator ""
setw -g window-status-style "NONE,fg=#88929d,bg=#010409"
setw -g window-status-format "#[fg=#010409,bg=#010409,nobold,nounderscore,noitalics]#[fg=#eef0f2,bg=#010409,nobold,nounderscore,noitalics] #I  #W #F #[fg=#010409,bg=#010409,nobold,nounderscore,noitalics]"
setw -g window-status-current-format "#[fg=#010409,bg=#055d20,nobold,nounderscore,noitalics]#[fg=#ffffff,bg=#055d20,bold] #I  #W #F #[fg=#055d20,bg=#010409,nobold,nounderscore,noitalics]"
