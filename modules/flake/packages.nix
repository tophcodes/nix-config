# Every directory under packages/ is a package of the same name.
{lib, ...}: {
  perSystem = {
    config,
    pkgs,
    inputs',
    ...
  }: {
    packages =
      (lib.filesystem.packagesFromDirectoryRecursive {
        inherit (pkgs) callPackage;
        directory = ../../packages;
      })
      // {
        # Both need helpers (installAgentSkills) that only nixpkgs master has.
        # callPackage resolves arguments from nixpkgs, not from this directory,
        # so the app gets the herdr-core built here by hand.
        herdr-core = inputs'.master.legacyPackages.callPackage ../../packages/herdr-core/package.nix {};
        herdr-desktop = inputs'.master.legacyPackages.callPackage ../../packages/herdr-desktop/package.nix {
          inherit (config.packages) herdr-core;
        };
      };
  };
}
