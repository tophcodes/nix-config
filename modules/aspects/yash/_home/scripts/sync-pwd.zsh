# Shell → yazi: follow every cd. No-op outside the yash session.
_yash_sync() {
  [[ -n "$YASH_SYNC_ID" ]] && ya emit-to "$YASH_SYNC_ID" cd "$PWD" 2>/dev/null
}
autoload -Uz add-zsh-hook
add-zsh-hook chpwd _yash_sync
