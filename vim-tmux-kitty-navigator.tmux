#!/usr/bin/env bash

# # # TMUX KITTY NAVIGATOR # # #
# Smart pane switching with awareness of Vim splits.
# Keybinds
is_vim="ps -o state= -o comm= -t '#{pane_tty}' \
    | grep -iqE '^[^TXZ ]+ +(\\S+\\/)?g?(view|l?n?vim?x?|fzf)(diff)?$'"
tmux bind-key -n 'C-S-Left' if-shell "$is_vim" 'send-keys C-S-Left'  'if-shell "[ #{pane_at_left} != 1 ]" "select-pane -L" "run '"'kitten @focus-window --match neighbor:left'"'"'
tmux bind-key -n 'C-S-Down' if-shell "$is_vim" 'send-keys C-S-Down'  'if-shell "[ #{pane_at_bottom} != 1 ]" "select-pane -D" "run '"'kitten @focus-window --match neighbor:bottom'"'"'
tmux bind-key -n 'C-S-Up' if-shell "$is_vim" 'send-keys C-S-Up'  'if-shell "[ #{pane_at_top} != 1 ]" "select-pane -U" "run '"'kitten @focus-window --match neighbor:top '"'"'
tmux bind-key -n 'C-S-Right' if-shell "$is_vim" 'send-keys C-S-Right'  'if-shell "[ #{pane_at_right} != 1 ]" "select-pane -R" "run '"'kitten @focus-window --match neighbor:right '"'"  
