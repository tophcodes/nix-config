# Shell → yazi: follow every cd. No-op outside the yash session.
__yash_sync() {
  [[ -n "$YASH_SYNC_ID" && "$PWD" != "$__YASH_LAST_PWD" ]] || return 0
  __YASH_LAST_PWD=$PWD
  ya emit-to "$YASH_SYNC_ID" cd "$PWD" 2>/dev/null
}
PROMPT_COMMAND="__yash_sync${PROMPT_COMMAND:+;$PROMPT_COMMAND}"
