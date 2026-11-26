#!/usr/bin/env bash
# yash-toggle — cycle yazi pane through modes: hidden → dir → multi → full → hidden
SESSION=yash
t() { tmux -L "$SESSION" "$@"; }

MODE=$(t show -gqv @yash_mode 2>/dev/null)
MODE=${MODE:-hidden}
YAZI=$(t show -gqv @yash_yazi_pane 2>/dev/null)

win_w() { t display -p '#{window_width}'; }
is_zoomed() { [ "$(t display -p '#{window_zoomed_flag}')" = "1" ]; }

show_at() {
  local pct=$1
  t join-pane -s "$YAZI" -t "$SESSION":0 -h -b -l "${pct}%"
}

case "$MODE" in
  hidden)
    W=$(win_w)
    if   [ "$W" -ge 180 ]; then show_at 45; t set -g @yash_mode multi
    elif [ "$W" -ge 100 ]; then show_at 25; t set -g @yash_mode dir
    else show_at 50; t resize-pane -Z -t "$YAZI"; t set -g @yash_mode full
    fi
    ;;
  dir)
    t resize-pane -t "$YAZI" -x 45%
    t set -g @yash_mode multi
    ;;
  multi)
    t resize-pane -Z -t "$YAZI"
    t set -g @yash_mode full
    ;;
  full)
    is_zoomed && t resize-pane -Z -t "$YAZI"  # unzoom
    t break-pane -s "$YAZI" -d -n yazi
    t select-window -t "$SESSION":0
    t set -g @yash_mode hidden
    ;;
esac
