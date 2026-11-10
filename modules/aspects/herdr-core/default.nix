# A machine the herdr workbench's tabs run on: devkit's herdr module installs
# what the mods run there (hx, jj, git), registers the Claude Code status hooks
# and, for the users in `devkit.herdr.core.users`, starts herdr-core (`hc`) at
# boot. This aspect supplies the herdr-core package.
{inputs, ...}: {
  flake.modules.nixos.herdr-core = {pkgs, ...}: {
    imports = [inputs.devkit.modules.nixos.herdr];

    # Only in nixpkgs master so far.
    devkit.herdr.core.package = inputs.master.legacyPackages.${pkgs.stdenv.hostPlatform.system}.herdr-core;
  };
}
