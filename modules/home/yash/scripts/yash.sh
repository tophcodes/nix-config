# yash — tmux session with yazi (left) synced to a shell (right).
# Usage: yash [shell-cmd]   (default: login shell)
SESSION=yash
SYNC_ID=4242
SHELL_CMD="${1-}"

if ! tmux has-session -t "$SESSION" 2>/dev/null; then
  tmux new-session -d -s "$SESSION" -c "$HOME" -e YASH_SYNC_ID="$SYNC_ID"
  tmux split-window -h -t "$SESSION" -c "$HOME" ${SHELL_CMD:+"$SHELL_CMD"}
  tmux send-keys -t "$SESSION".0 "yazi --client-id $SYNC_ID" Enter
fi
exec tmux attach -t "$SESSION"
