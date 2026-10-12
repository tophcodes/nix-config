# Pick a bookmark, tag or workspace working copy with fzf and start a new
# empty change on it. Text that matches no candidate is passed to `jj new`
# as typed, so change IDs and revsets work too.

# A workspace goes stale when another workspace rewrites the commit it sits
# on, and jj then refuses every command here. update-stale keeps unsnapshotted
# edits in a recovery commit, so running it unasked loses nothing.
if ! err=$(jj log -r @ --no-graph -T '' 2>&1 >/dev/null); then
  case $err in
    *"working copy is stale"*)
      echo "Workspace is stale, updating it first."
      jj workspace update-stale
      ;;
    *)
      echo "$err" >&2
      exit 1
      ;;
  esac
fi

# fzf exits non-zero when nothing matches (the typed query is still printed)
# and when aborted (nothing printed); only the output decides.
target=$(
  {
    jj bookmark list --all-remotes \
      -T 'if(remote != "git", name ++ if(remote, "@" ++ remote) ++ "\n")'
    jj tag list -T 'name ++ "\n"'
    jj workspace list -T 'name ++ "@\n"'
  } | sort -u |
    fzf --print-query --prompt 'jj new> ' | tail -n 1
) || true

[ -n "$target" ] || exit 0
jj new "$target"
