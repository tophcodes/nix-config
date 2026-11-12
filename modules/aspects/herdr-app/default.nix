# The herdr desktop app and herdr-core (`hc`), the terminal runtime it drives.
# Both come from nixpkgs master until a channel carries them. The machine side
# of the workbench (hx, jj, git, the Claude Code status hooks) comes from the
# NixOS aspect herdr-core, which a host with this app imports as well.
{inputs, ...}: {
  flake.modules.homeManager.herdr-app = {pkgs, ...}: {
    # The workbench layout and its mods, linked from ~/code/devkit/herdr.
    imports = [inputs.devkit.modules.homeManager.herdr];

    home.packages = with inputs.master.legacyPackages.${pkgs.stdenv.hostPlatform.system}; [
      herdr-desktop
      herdr-core
    ];
  };
}
