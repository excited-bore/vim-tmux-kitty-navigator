Vim Tmux Kitty Navigator
==================

This plugin is a combined port from
- [vim-tmux-navigator](https://github.com/knubie/vim-kitty-navigator), 
- [vim-kitty-navigator](https://github.com/knubie/vim-kitty-navigator)
- [kitty-vim-tmux-navigator](https://github.com/knubie/vim-kitty-navigator)

[kitty-vim-tmux-navigator](https://github.com/knubie/vim-kitty-navigator) didn't work so I decided to make my own port that only works but also works 3 layers deep (Navigation for vim splits, inside tmux, inside kitty). 
The aim is excactly the same: to make navigation between Kitty windows, tmux panes, and vim splits seamless. 

The script works by letting a childprocess of kitty (kitten) detect what kind of programs are running and passing encoded keymappings based on whether it's vim. 
For tmux, wich is set using pathvariables, we have to reinitialize our pane everytime we start/close a tmux session so we can manually appoint tmux' pathvariable.

Also, nvim can't do system calls as root unless file is specifically opened with sudo, so the plugiwon't respond.  

**NOTE**:
- This requires kitty v0.13.1 or higher.
- This requires tmux v1.8 or higher (Newer version of tmux with 'pane_at_*' format feature.)

Usage
-----

One big difference is that all the other plugins start with vim-motion based bindings (ctrl-).
I don't use these, so this plugin comes with basic arrow key bindings at default.

The following mappings are provided for you to move between
vim splits, tmux panes, and kitty window seamlessly.

- `<ctrl-shift-left>` => Left
- `<ctrl-shift-down>` => Down
- `<ctrl-shift-up>` => Up
- `<ctrl-shift-right>` => Right

If you want to use alternate key mappings, see the [configuration section](#custom-keybinds) below

Installation
------------

### VIM

If you don't have a preferred installation method, I recommend using [vim-plug](https://github.com/junegunn/vim-plug).
Assuming you have vim-plug installed and configured, the following steps will
install the plugin:

Add the following line to your `~/.vimrc` file

```vim
Plug 'excited-bore/vim-tmux-kitty-navigator', { 'build' : 'mkdir -p ~/.config/kitty/ && cd ~/.vim/plugins/vim-tmux-kitty-navigator && cp -f ./pass_keys.py ~/.config/kitty/;' }
```
And then run the plugin installation function (`PlugInstall`)

In the installation directory there's a file `pass_keys.py` that needs to be copied/moved over to your kitty config directory (`~/.config/kitty/`). This is what the 'do' (post-installation hook) does for you already in the given line.

### lazy.nvim

If you are using [lazy.nvim](https://github.com/folke/lazy.nvim). Add the following plugin to your configuration.

```lua
{
  "excited-bore/vim-tmux-kitty-navigator",
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
Plugin 'excited-bore/vim-tmux-kitty-navigator', { 'build': 'mkdir -p ~/.config/kitty/ && cd ~/.vim/plugins/vim-tmux-kitty-navigator && cp -f ./*.py ~/.config/kitty/'}
```

## Custom keybinds

If you want to use custom keybinds, set `let g:tmux_kitty_navigator_no_mappings = 1`

Again, default keybinds are:

```vim
  nnoremap <silent><C-S-Left> :<C-u>TmuxKittyNavigate Left<cr>
  nnoremap <silent><C-S-Down> :<C-u>TmuxKittyNavigate Down<cr>
  nnoremap <silent><C-S-Up> :<C-u>TmuxKittyNavigate Up<cr>
  nnoremap <silent><C-S-Right> :<C-u>TmuxKittyNavigate Right<cr>

  inoremap <silent><C-S-Left> <esc>:<C-u>TmuxKittyNavigate Left<cr>i
  inoremap <silent><C-S-Down> <esc>:<C-u>TmuxKittyNavigate Down<cr>i
  inoremap <silent><C-S-Up> <esc>:<C-u>TmuxKittyNavigate Up<cr>i
  inoremap <silent><C-S-Right> <esc>:<C-u>TmuxKittyNavigate Right<cr>i

  vnoremap <silent><C-S-Left> :<C-u>TmuxKittyNavigate Left<cr>gv
  vnoremap <silent><C-S-Down> :<C-u>TmuxKittyNavigate Down<cr>gv
  vnoremap <silent><C-S-Up> :<C-u>TmuxKittyNavigate Up<cr>gv
  vnoremap <silent><C-S-Right> :<C-u>TmuxKittyNavigate Right<cr>gv
```

Sinds this plugin is heavily based on `vim-tmux-navigator`, it reuses some of the configuration variables, namely:

```vim
 let g:tmux_navigator_save_on_switch
 let g:tmux_navigator_disable_when_zoomed
 let g:tmux_navigator_preserve_zoom
 let g:tmux_navigator_no_wrap
```
You don't need to reconfigure these if you've already used `vim-tmux-navigator` and you're migrating.
Also, like for the original plugin, these are all 0 at default

### KITTY

In addition to copying over the `pass_keys.py` and `get_layout.py` to `~/.config/kitty/`, also add the following keybindings to your `~/.config/kitty/kitty.conf` file.

Open kitty and press `ctrl+shift+f2` and add:

```sh
map ctrl+shift+left  kitten pass_keys.py left   ctrl+shift+left
map ctrl+shift+down  kitten pass_keys.py bottom ctrl+shift+down
map ctrl+shift+up    kitten pass_keys.py up     ctrl+shift+up
map ctrl+shift+right kitten pass_keys.py right  ctrl+shift+right
```

Also enable `allow_remote_control`, set `listen_on` to a non-'@' value (plays badly with remote control over SSH): 

```conf
allow_remote_control yes
listen_on unix:/tmp/mykitty
```

**OR**

Start kitty with the `listen_on` option so that vim can send commands to it.

```conf
kitty -o allow_remote_control=yes --listen-on unix:/tmp/mykitty
```

### TMUX

Add this plugin to your `.tmux.conf` if you're ok with the default keybinds (and you're using [TPM](https://github.com/tmux-plugins/tpm)):

```conf
set -g @plugin 'excited-bore/vim-tmux-kitty-navigator'
```
Don't forget to install your plugins

**Otherwise**

Add the following snippet to your `.tmux.conf` and change to your liking:

```sh
# # # VIM TMUX KITTY NAVIGATOR # # #

# Keybinds
is_vim="ps -o state= -o comm= -t '#{pane_tty}' \
    | grep -iqE '^[^TXZ ]+ +(\\S+\\/)?g?(view|l?n?vim?x?|fzf)(diff)?$'"
bind-key -n 'C-S-Left' if-shell "$is_vim" 'send-keys C-S-Left'  'if-shell "[ #{pane_at_left} != 1 ]" "select-pane -L" "run '"'kitten @focus-window --match neighbor:left || true'"'"'
bind-key -n 'C-S-Down' if-shell "$is_vim" 'send-keys C-S-Down'  'if-shell "[ #{pane_at_bottom} != 1 ]" "select-pane -D" "run '"'kitten @focus-window --match neighbor:bottom || true'"'"'
bind-key -n 'C-S-Up' if-shell "$is_vim" 'send-keys C-S-Up'  'if-shell "[ #{pane_at_top} != 1 ]" "select-pane -U" "run '"'kitten @focus-window --match neighbor:top || true'"'"'
bind-key -n 'C-S-Right' if-shell "$is_vim" 'send-keys C-S-Right'  'if-shell "[ #{pane_at_right} != 1 ]" "select-pane -R" "run '"'kitten @focus-window --match neighbor:right || true'"'"' 
```

### SSH Compatibility
-----------------

With the settings above, navigation should work well locally. But if you need kitty-tmux navigation also working through SSH, we need to do some extra configuration:

1. Install kitty on your remote machine. [How To](https://sw.kovidgoyal.net/kitty/binary.html?highlight=install).
2. Enable remote control forwarding.

Make a new file on the local machine `~/.config/kitty/ssh.conf` and add:

```conf
forward_remote_control yes 
```
Configuring the functionality over an SSH connection was tricky, sinds we can't actrively check using kitty/kittens whether we're on an SSH connection using tmux. So af for now at least, the script checks for window title changes with 'tmux' in it. It works, but do keep in mind that crazy SSH oneliners can unfortunatly result in the plugin not working as intended.

Also don't forget to set an alias for kitty's builtin SSH 'kitten' process:

```sh
alias ssh="kitten ssh user@host"
```

This plugin isn't perfect, but it definitly does the job locally. 
Don't forget to install the tmux plugin on your remote system as well. 
