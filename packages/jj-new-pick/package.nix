{pkgs, ...}:
pkgs.writeShellApplication {
  name = "jj-new-pick";
  # jj is taken from the caller's PATH: this package set pins an older jj
  # than the one home-manager installs, and an older jj must not write to a
  # repo the newer one manages.
  runtimeInputs = [pkgs.fzf pkgs.coreutils];
  text = builtins.readFile ./jj-new-pick;
}
