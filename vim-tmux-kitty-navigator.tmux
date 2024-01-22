#!/usr/bin/env bash


# Kitty Tmux navigator
# SSH aware kitty change window
tmux if-shell '[ $SSH_TTY ]' 'to="--to=tcp:localhost:$KITTY_PORT "' 'to=""'
move='kitty @ ${to} kitten focus-window --match'

# # # TMUX KITTY NAVIGATOR # # #
# Smart pane switching with awareness of Vim splits.
is_vim="ps -o state= -o comm= -t '#{pane_tty}' \
    | grep -iqE '^[^TXZ ]+ +(\\S+\\/)?g?(view|l?n?vim?x?|fzf)(diff)?$'"
tmux bind-key -n 'C-S-Left' if-shell "$is_vim" 'send-keys C-S-Left'  'if-shell "[ #{pane_at_left} != 1 ]" "select-pane -L" "run '"'$move neighbor:left || true'"'"'
tmux bind-key -n 'C-S-Down' if-shell "$is_vim" 'send-keys C-S-Down'  'if-shell "[ #{pane_at_bottom} != 1 ]" "select-pane -D" "run '"'$move neighbor:bottom || true'"'"'
tmux bind-key -n 'C-S-Up' if-shell "$is_vim" 'send-keys C-S-Up'  'if-shell "[ #{pane_at_top} != 1 ]" "select-pane -U" "run '"'$move neighbor:up || true'"'"'
tmux bind-key -n 'C-S-Right' if-shell "$is_vim" 'send-keys C-S-Right'  'if-shell "[ #{pane_at_right} != 1 ]" "select-pane -R" "run '"'$move neighbor:right || true'"'"'

version_pat='s/^tmux[^0-9]*([.0-9]+).*/\1/p'
tmux_version="$(tmux -V | sed -En "$version_pat")"
tmux setenv -g tmux_version "$tmux_version"
#if-shell -b '[ "$(echo "$tmux_version < 3.0" | bc)" = 1 ]' \
#    "bind-key -n 'C-\\' if-shell \"$is_vim\" 'send-keys C-\\'  'select-pane -l'"
#if-shell -b '[ "$(echo "$tmux_version >= 3.0" | bc)" = 1 ]' \
#    "bind-key -n 'C-\\' if-shell \"$is_vim\" 'send-keys C-\\\\'  'select-pane -l'"
#  
