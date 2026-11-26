# shellcheck shell=bash
# yash: tmux session with yazi synced to a shell.
# Usage: yash [shell-cmd]   (default: login shell)
SESSION=yash
SYNC_ID=4242
SHELL_CMD="${1-}"

t() { tmux -L "$SESSION" "$@"; }

if ! t has-session -t "$SESSION" 2>/dev/null; then
  # Window 0: shell
  t -f "$YASH_TMUX_CONF" new-session -d -s "$SESSION" -c "$HOME" \
    -e YASH_SYNC_ID="$SYNC_ID" ${SHELL_CMD:+"$SHELL_CMD"}
  SHELL_PANE=$(t display -p -t "$SESSION":0.0 '#{pane_id}')
  t set -g @yash_shell_pane "$SHELL_PANE"

  # Window "yazi": always running, hidden until toggled in.
  t new-window -t "$SESSION" -n yazi "yazi --client-id $SYNC_ID"
  YAZI_PANE=$(t display -p -t "$SESSION":yazi.0 '#{pane_id}')
  t set -g @yash_yazi_pane "$YAZI_PANE"
  t set -p -t "$YAZI_PANE" remain-on-exit on

  t set -g @yash_mode hidden
  t select-window -t "$SESSION":0
fi
exec tmux -L "$SESSION" attach -t "$SESSION"
