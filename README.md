Tmux Kitty Vim Navigator
==================

This plugin is a combined port from
- [vim-tmux-navigator](https://github.com/knubie/vim-kitty-navigator), 
- [vim-kitty-navigator](https://github.com/knubie/vim-kitty-navigator)
- [kitty-vim-tmux-navigator](https://github.com/knubie/vim-kitty-navigator)

[kitty-vim-tmux-navigator](https://github.com/knubie/vim-kitty-navigator) didn't work so I decided to make my own port that only works but also works 3 layers deep (Navigation for vim splits, inside tmux, inside kitty). 
The aim is excactly the same: to make navigation between Kitty windows, tmux panes, and vim splits seamless. 

The script works by letting a childprocess of kitty (kitten) detect what kind of programs are running and passing encoded keymappings based on whether it's vim or tmux. Sadly, detecting whether tmux is running through SSH is something that can't be done using the current method. SSH itself can be detected though, so sending keymappings to a ssh-session that starts up using tmux is a possibility. Further explained in the SSH section.


**NOTE**:
- This requires kitty v0.13.1 or higher.
- This requires tmux v1.8 or higher (Newer version of tmux with 'pane_at_*' format feature.)

Usage
-----

One big difference is that all the other plugins start with vim-motion based bindings (ctrl-).
I don't use these, so this plugin comes with basic arrow key bindings at default.

The following mappings are provided for you to move between
Vim splits, tmux panes, and kitty window seamlessly.

- `<ctrl-shift-left>` => Left
- `<ctrl-shift-down>` => Down
- `<ctrl-shift-up>` => Up
- `<ctrl-shift-right>` => Right

If you want to use alternate key mappings, see the [configuration section
below][].

Installation
------------

### VIM

If you don't have a preferred installation method, I recommend using [vim-plug](https://github.com/junegunn/vim-plug).
Assuming you have vim-plug installed and configured, the following steps will
install the plugin:

Add the following line to your `~/.vimrc` file

```vim
Plug 'excited-bore/tmux-kitty-vim-navigator', { 'do': 'cp -f ./pass_keys.py ~/.config/kitty/'}

```
And then run the plugin installation function (`PlugInstall`)

In the installation directory there's a file `pass_keys.py` that needs to be copied/moved over to your kitty config directory (`~/.config/kitty/`). This is what the 'do' (post-installation hook) does for you already in the given line.

### lazy.nvim

If you are using [lazy.nvim](https://github.com/folke/lazy.nvim). Add the following plugin to your configuration.

```lua
{
  "excited-bore/tmux-kitty-vim-navigator",
  cmd = {
    "TmuxKittyNavigateLeft",
    "TmuxKittyNavigateDown",
    "TmuxKittyNavigateUp",
    "TmuxKittyNavigateRight"
  },
  keys = {
    { "<c-s-left>", "<cmd><C-U>TmuxKittyNavigateLeft<cr>" },
    { "<c-s-down>", "<cmd><C-U>TmuxKittyNavigateDown<cr>" },
    { "<c-s-up>", "<cmd><C-U>TmuxKittyNavigateUp<cr>" },
    { "<c-s-right>", "<cmd><C-U>TmuxKittyNavigateRight<cr>" }
  },
}
```

Then, restart Neovim and lazy.nvim will automatically install the plugin and configure the keybindings.

If you want to use [lazy.nvim](https://github.com/folke/lazy.nvim), but still want to keep the advantage of one easy configuration line, I highly suggest this [vim-plug adapter script](https://gist.github.com/BlueDrink9/474b150c44d41b80934990c0acfb00be)
The configuration would become this:

```vim
Plugin 'excited-bore/tmux-kitty-vim-navigator', { 'afterInstall': 'AfterInstallKittyTmuxVim'}
function! AfterInstallKittyTmuxVim()
    call system('(cd ~/.vim/plugins/kitty-vim-tmux-navigator && cp -f ./pass_keys.py ~/.config/kitty/)')
endf

```


### KITTY

In addition to copying over the `~/.vim/plugins/tmux-kitty-vim-navigator/pass_keys.py` to `~/.config/kitty/`, also add the following keybindings to your `~/.config/kitty/kitty.conf` file.

Open kitty and press `ctrl+shift+f2` and add:

```sh
map ctrl+shift+left  kitten pass_keys.py left   ctrl+shift+left
map ctrl+shift+down  kitten pass_keys.py bottom ctrl+shift+down
map ctrl+shift+up    kitten pass_keys.py up     ctrl+shift+up
map ctrl+shift+right kitten pass_keys.py right  ctrl+shift+right
```

Also enable `allow_remote_control` and `listen_on` option:

```conf
allow_remote_control yes
listen_on unix:/tmp/mykitty
```

**OR**

Start kitty with the `listen_on` option so that vim can send commands to it.

```
kitty -o allow_remote_control=yes --listen-on unix:/tmp/mykitty
```

The listening address can be customized in your vimrc by setting `g:kitty_navigator_listening_on_address`. It defaults to `unix:/tmp/mykitty`.

### TMUX

If you're using [TPM](https://github.com/tmux-plugins/tpm), just add this snippet to your tmux.conf:

```conf
set -g @plugin 'excited-bore/tmux-kitty-vim-navigator'
```
And update your plugin

**Otherwise**

Add the following snippet to your tmux.conf:

```sh
# # # VIM TMUX KITTY NAVIGATOR # # #

# SSH aware kitty change window
if-shell '[ $SSH_TTY ]' 'to="--to=tcp:localhost:$KITTY_PORT "' 'to=""'
move='kitty @ ${to} kitten focus-window --match'

# Keybinds
is_vim="ps -o state= -o comm= -t '#{pane_tty}' \
    | grep -iqE '^[^TXZ ]+ +(\\S+\\/)?g?(view|l?n?vim?x?|fzf)(diff)?$'"
bind-key -n 'C-S-Left' if-shell "$is_vim" 'send-keys C-S-Left'  'if-shell "[ #{pane_at_left} != 1 ]" "select-pane -L" "run '"'$move neighbor:left || true'"'"'
bind-key -n 'C-S-Down' if-shell "$is_vim" 'send-keys C-S-Down'  'if-shell "[ #{pane_at_bottom} != 1 ]" "select-pane -D" "run '"'$move neighbor:bottom || true'"'"'
bind-key -n 'C-S-Up' if-shell "$is_vim" 'send-keys C-S-Up'  'if-shell "[ #{pane_at_top} != 1 ]" "select-pane -U" "run '"'$move neighbor:up || true'"'"'
bind-key -n 'C-S-Right' if-shell "$is_vim" 'send-keys C-S-Right'  'if-shell "[ #{pane_at_right} != 1 ]" "select-pane -R" "run '"'$move neighbor:right || true'"'"'
```

### SSH Compatibility
-----------------

With the settings above, navigation should work well locally. But if you need kitty-tmux navigation also working through SSH, consider that this only is feasible when ssh-ing and immediatly starting a tmux session. Without immediatly starting said tmux session, the script will pass keys directly to the bare remote shell wich will not work properly. So, if comfortable with always starting ssh with tmux, follow these steps:

1. Install kitty on your remote machine. [How To](https://sw.kovidgoyal.net/kitty/binary.html?highlight=install).
2. Enable remote control forwarding.

Make a new file `~/.config/kitty/ssh.conf` and add:

```
forward_remote_control yes 
```
3. Change these lines in `~/.config/kitty/pass_keys.py` (starting at line 59)
```
elif is_program(w, "ssh"):  
        print("Ssh passed")
        for keymap in args[2].split(">"):
             encoded = encode_key_mapping(w, keymap)
             w.write_to_child(encoded)    
```

5. Add the following alias to your remote machine's `.bashrc` or something similar on other shell:

```sh
alias ssh="kitty +kitten ssh user@host 'tmux'"

```
where user is the remote user and host the remote ip. Mostly note the 'tmux'. 

This plugin isn't perfect, but it definitly does the job speaking strictly locally. And I believe that I, like a lot of other people, prefer starting up a tmux session while ssh'ing anyway.

Don't forget to install the tmux plugin on your remote system also. 
If you're sick of always using tmux remotly, you can always comment out lines 59 - 64 in `~/.config/kitty/pass_keys.py` again.
