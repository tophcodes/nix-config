# The herdr desktop app and herdr-core (`hc`), the terminal runtime it drives.
# Both come from the nixpkgs-herdr input until the packages land in nixpkgs.
{inputs, ...}: {
  flake.modules.homeManager.herdr-app = {pkgs, ...}: {
    home.packages = with inputs.nixpkgs-herdr.legacyPackages.${pkgs.stdenv.hostPlatform.system}; [
      herdr-desktop
      herdr-core
    ];
  };
}
