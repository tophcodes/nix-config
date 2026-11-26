# One home and one NixOS host that import every aspect of their class. They
# have no hardware behind them and are never activated: `nix flake check`
# evaluates them, so a module that stops evaluating fails here first.
{
  inputs,
  self,
  lib,
  ...
}: let
  system = "x86_64-linux";
  homeModules = lib.attrValues self.modules.homeManager;
  nixosModules = lib.attrValues self.modules.nixos;
in {
  flake = {
    homeConfigurations.example = inputs.home-manager.lib.homeManagerConfiguration {
      pkgs = import inputs.unstable {
        inherit system;
        config.allowUnfree = true;
        overlays = [inputs.devkit.overlays.helix];
      };
      extraSpecialArgs = {inherit inputs;};
      modules =
        homeModules
        ++ [
          {
            fleet.user.name = "example";
            home.stateVersion = "25.11";
          }
        ];
    };

    nixosConfigurations.example = inputs.nixpkgs.lib.nixosSystem {
      specialArgs = {
        inherit inputs;
        hostname = "example";
      };
      modules =
        nixosModules
        ++ [
          {
            nixpkgs.hostPlatform = system;
            fleet.user.name = "example";
            nixpkgs.config.allowUnfree = true;
            system.stateVersion = "26.05";
            boot.loader.systemd-boot.enable = true;
            fileSystems."/" = {
              device = "/dev/disk/by-label/nixos";
              fsType = "ext4";
            };
          }
        ];
    };
  };

  # Forces both evaluations without building either closure.
  perSystem = {pkgs, ...}: {
    checks.examples = pkgs.writeText "examples" ''
      ${builtins.unsafeDiscardStringContext self.homeConfigurations.example.activationPackage.drvPath}
      ${builtins.unsafeDiscardStringContext self.nixosConfigurations.example.config.system.build.toplevel.drvPath}
    '';
  };
}
