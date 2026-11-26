# Shell → yazi: follow every cd. No-op outside the yash session.
$env.config.hooks.env_change.PWD = (
  $env.config.hooks.env_change.PWD? | default [] | append {|before, after|
    if "YASH_SYNC_ID" in $env {
      try { ya emit-to $env.YASH_SYNC_ID cd $after }
    }
  }
)
