" Maps <C-S-Left/Down/Up/Right> to switch vim splits in the given direction. If there are
" no more windows in that direction, forwards the operation to kitty.
:autocmd BufWinLeave * !

if exists("g:loaded_tmux_kitty_navigator") || &cp || v:version < 700
  finish
endif
let g:loaded_tmux_kitty_navigator = 1

command! TmuxKittyNavigateLeft   call TmuxKittyNavigate('h')
command! TmuxKittyNavigateDown   call TmuxKittyNavigate('j')
command! TmuxKittyNavigateUp     call TmuxKittyNavigate('k')
command! TmuxKittyNavigateRight  call TmuxKittyNavigate('l') 

if !get(g:, 'tmux_kitty_navigator_no_mappings', 0)
    nnoremap <silent><C-S-Left> :<C-u>TmuxKittyNavigateLeft<cr>
    nnoremap <silent><C-S-Down> :<C-u>TmuxKittyNavigateDown<cr>
    nnoremap <silent><C-S-Up> :<C-u>TmuxKittyNavigateUp<cr>
    nnoremap <silent><C-S-Right> :<C-u>TmuxKittyNavigateRight<cr>

    inoremap <silent><C-S-Left> <esc>:<C-u>TmuxKittyNavigateLeft<cr>i
    inoremap <silent><C-S-Down> <esc>:<C-u>TmuxKittyNavigateDown<cr>i
    inoremap <silent><C-S-Up> <esc>:<C-u>TmuxKittyNavigateUp<cr>i
    inoremap <silent><C-S-Right> <esc>:<C-u>TmuxKittyNavigateRight<cr>i

    vnoremap <silent><C-S-Left> :<C-u>TmuxKittyNavigateLeft<cr>gv
    vnoremap <silent><C-S-Down> :<C-u>TmuxKittyNavigateDown<cr>gv
    vnoremap <silent><C-S-Up> :<C-u>TmuxKittyNavigateUp<cr>gv
    vnoremap <silent><C-S-Right> :<C-u>TmuxKittyNavigateRight<cr>gv   
endif


let s:mappings = {'h': 'left', 'j': 'bottom', 'k': 'top', 'l': 'right'}

function! s:VimNavigate(direction)
  try
    execute 'wincmd ' . a:direction
  catch
    echohl ErrorMsg | echo 'E11: Invalid in command-line window; <CR> executes, CTRL-C quits: wincmd k' | echohl None
  endtry
endfunction

"####### TMUX ########
" https://github.com/NikoKS/kitty-vim-tmux-navigator

if !exists("g:tmux_navigator_save_on_switch")
  let g:tmux_navigator_save_on_switch = 0
endif

if !exists("g:tmux_navigator_disable_when_zoomed")
  let g:tmux_navigator_disable_when_zoomed = 0
endif

if !exists("g:tmux_navigator_preserve_zoom")
  let g:tmux_navigator_preserve_zoom = 0
endif

if !exists("g:tmux_navigator_no_wrap")
  let g:tmux_navigator_no_wrap = 0
endif

function! s:TmuxOrTmateExecutable()
  return (match($TMUX, 'tmate') != -1 ? 'tmate' : 'tmux')
endfunction

function! s:TmuxVimPaneIsZoomed()
  return s:TmuxCommand("display-message -p '#{window_zoomed_flag}'") == 1
endfunction

function! s:TmuxSocket()
  " The socket path is the first value in the comma-separated list of $TMUX.
  return split($TMUX, ',')[0]
endfunction

function! s:TmuxCommand(args)
  let cmd = s:TmuxOrTmateExecutable() . ' -S ' . s:TmuxSocket() . ' ' . a:args
  let l:x=&shellcmdflag
  let &shellcmdflag='-c'
  let retval=system(cmd)
  let &shellcmdflag=l:x
  return retval
endfunction 

function! s:TmuxNavigatorProcessList()
  echo s:TmuxCommand("run-shell 'ps -o state= -o comm= -t ''''#{pane_tty}'''''")
endfunction
command! TmuxNavigatorProcessList call s:TmuxNavigatorProcessList()

let s:tmux_is_last_pane = 0
augroup tmux_navigator
  au!
  autocmd WinEnter * let s:tmux_is_last_pane = 0
augroup END

function! s:NeedsVitalityRedraw()
  return exists('g:loaded_vitality') && v:version < 704 && !has("patch481")
endfunction

function! s:ShouldForwardNavigationBackToTmux(tmux_last_pane, at_tab_page_edge)
  if g:tmux_navigator_disable_when_zoomed && s:TmuxVimPaneIsZoomed()
    return 0
  endif
  return a:tmux_last_pane || a:at_tab_page_edge
endfunction


function! s:TmuxAwareNavigate(direction)
    let nr = winnr() 
    let tmux_last_pane = (a:direction == 'p' && s:tmux_is_last_pane)
    if !tmux_last_pane
        call s:VimNavigate(a:direction)
    endif
    let at_tab_page_edge = (nr == winnr())
    " Forward the switch panes command to tmux if:
    " a) we're toggling between the last tmux pane;
    " b) we tried switching windows in vim but it didn't have effect.
    if s:ShouldForwardNavigationBackToTmux(tmux_last_pane, at_tab_page_edge)
    if g:tmux_navigator_save_on_switch == 1
      try
        update " save the active buffer. See :help update
      catch /^Vim\%((\a\+)\)\=:E32/ " catches the no file name error
      endtry
    elseif g:tmux_navigator_save_on_switch == 2
      try
        wall " save all the buffers. See :help wall
      catch /^Vim\%((\a\+)\)\=:E141/ " catches the no file name error
      endtry
    endif
    let args = 'select-pane -t ' . shellescape($TMUX_PANE) . ' -' . tr(a:direction, 'phjkl', 'lLDUR')
    if g:tmux_navigator_preserve_zoom == 1
      let l:args .= ' -Z'
    endif
    if g:tmux_navigator_no_wrap == 1
      let args = 'if -F "#{pane_at_' . s:mappings[a:direction] . '}" "" "' . args . '"'
    endif
    silent call s:TmuxCommand(args)
    if s:NeedsVitalityRedraw()
      redraw!
    endif
    let s:tmux_is_last_pane = 1
    else
    let s:tmux_is_last_pane = 0
    endif
endfunction


"####### KITTY ########
" https://github.com/knubie/vim-kitty-navigator/tree/master

function! s:KittyCommand(args)
  let pw = get(g:, 'kitty_navigator_password', 0)
  let pw_s = pw != "" ? '--password="' . pw . '" ' : ''
  let cmd = 'kitty @ ' . pw_s . a:args
  return system(cmd)
endfunction

let s:kitty_is_last_pane = 0

augroup kitty_navigator
  au!
  autocmd WinEnter * let s:kitty_is_last_pane = 0
augroup END

function! s:KittyIsInStackLayout()
  let layout = s:KittyCommand('kitten get_layout.py')
  return layout =~ 'stack'
endfunction

function! s:KittyAwareNavigate(direction)
  let nr = winnr()
  let kitty_last_pane = (a:direction == 'p' && s:kitty_is_last_pane)
  if !kitty_last_pane
    call s:VimNavigate(a:direction)
  endif
  let at_tab_page_edge = (nr == winnr())

  let kitty_is_in_stack_layout = s:KittyIsInStackLayout()
  let stack_layout_enabled = get(g:, 'kitty_navigator_enable_stack_layout', 0)

  let can_navigate_in_layout = !kitty_is_in_stack_layout || stack_layout_enabled 
  

  if (kitty_last_pane || at_tab_page_edge) && can_navigate_in_layout 
    let args = 'focus-window --match neighbor:' . s:mappings[a:direction]
    silent call s:KittyCommand(args)
    let s:kitty_is_last_pane = 1
  else
    let s:kitty_is_last_pane = 0
  endif
endfunction

function! TmuxKittyNavigate(direction)
    if empty($TMUX)  
        call s:KittyAwareNavigate(a:direction)
    else
        let isLast = system('tmux display-message -p -F "#{pane_at_' .. s:mappings[a:direction] .. '}"')
        if isLast == 1
            call s:KittyAwareNavigate(a:direction)
        else
            call s:TmuxAwareNavigate(a:direction)
        endif
    endif
endfunction 
