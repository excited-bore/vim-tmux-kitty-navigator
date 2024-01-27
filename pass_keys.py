import kitty.conf.utils as ku
from kitty.key_encoding import KeyEvent, parse_shortcut
from kitty import keys
import re
import os

def main():
    pass

def is_vim(window, vim_id):
    fp = window.child.foreground_processes
    return any(re.search(vim_id, p['cmdline'][0] if len(p['cmdline']) else '', re.I) for p in fp)

def is_tmux(window):
    #ansr = os.popen(tmux_id).read()
    in_title=window.child_title
    print(in_title)
    # Is there a tmux client in a kittten, or (for ssh) just a simple check whether tmux is in title?
    # This isn't the best method but we steer with the rows we got
    if "tmux" in in_title:
        return True
    else:
        return False


def encode_key_mapping(window, key_mapping):
    mods, key = parse_shortcut(key_mapping)
    event = KeyEvent(
        mods=mods,
        key=key,
        shift=bool(mods & 1),
        alt=bool(mods & 2),
        ctrl=bool(mods & 4),
        super=bool(mods & 8),
        hyper=bool(mods & 16),
        meta=bool(mods & 32)
    ).as_window_system_event()

    return window.encoded_key(event)

from kittens.tui.handler import result_handler
@result_handler(type_of_input='text')
def handle_result(args, result, target_window_id, boss):
    """ Main entry point for the kitten. Decide wether to change window or pass
    the keypress
    Args:
        args (list): Extra arguments passed when calling this kitten
            [0] (str): kitten name
            [1] (str): direction to move
            [2] (str): key to pass
    The rest of the arguments comes from kitty
    """

    # get active window and tab from target_window_id
    w = boss.window_id_map.get(target_window_id)    
    vim_id = "n?vim"
    #tmux_id = "pstree -stp $(kitten @ ls | grep \"pid\" | tail -1 | head -1 | sed 's|.* \(.*\),|\1|' | grep 'tmux: client')"
    
    if w is None:
        return
     
    if is_tmux(w, tmux_id):
        print("Tmux passed")
        for keymap in args[2].split(">"):
            encoded = encode_key_mapping(w, keymap)
            w.write_to_child(encoded)
    elif is_vim(w, vim_id):  
        print("(N)vim passed")
        # Tmux is empty
        for keymap in args[2].split(">"):
            encoded = encode_key_mapping(w, keymap)
            w.write_to_child(encoded)
    # keywords not found, move to neighboring window instead
    else:
        boss.active_tab.neighboring_window(args[1])

handle_result.no_ui = True
