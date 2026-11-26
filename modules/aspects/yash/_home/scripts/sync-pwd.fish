# Shell → yazi: follow every cd. No-op outside the yash session.
if set -q YASH_SYNC_ID
  ya emit-to $YASH_SYNC_ID cd "$PWD" 2>/dev/null
end

