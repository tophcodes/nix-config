#!/usr/bin/env bash
# yash-cd DIR: called from yazi <C-s> to send a cd to the shell pane.
SESSION=yash
PANE=$(tmux -L "$SESSION" show -gqv @yash_shell_pane 2>/dev/null)
[[ -n "$PANE" ]] && tmux -L "$SESSION" send-keys -t "$PANE" " cd \"$1\"" Enter
