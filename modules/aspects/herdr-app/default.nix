# The herdr desktop app and herdr-core (`hc`), the terminal runtime it drives.
# Both are built from packages/herdr-desktop and packages/herdr-core: the
# workbench's link handler needs herdr-app 0.1.17 or newer, and nixpkgs master
# carries 0.1.15. Once nixpkgs has 0.1.17, take both from there and delete the
# two package directories. The machine side of the workbench (hx, jj, git, the
# Claude Code status hooks) comes from the NixOS aspect herdr-core, which a
# host with this app imports as well.
{inputs, ...}: {
  flake.modules.homeManager.herdr-app = {pkgs, ...}: {
    # The workbench layout and its mods, linked from ~/code/devkit/herdr.
    imports = [inputs.devkit.modules.homeManager.herdr];

    home.packages = with inputs.self.packages.${pkgs.stdenv.hostPlatform.system}; [
      herdr-desktop
      herdr-core
    ];
  };
}
