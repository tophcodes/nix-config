{
  # yash: a tmux session pairing yazi with a shell; see _home/default.nix.
  flake.modules.homeManager.yash = {imports = [./_home];};
}
