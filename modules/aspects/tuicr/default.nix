{
  config,
  inputs,
  ...
}: let
  # Bound out here on purpose: the home-manager module below shadows `config`
  # with its own, where `flake.lib` does not exist.
  inherit (config.flake.lib) aspects;
in {
  flake.modules.homeManager.tuicr = {pkgs, ...}: {
    imports = [
      (aspects.mkSymlinks {".config/tuicr" = ./config;})
    ];

    home.packages = [
      inputs.tuicr.packages.${pkgs.stdenv.hostPlatform.system}.default
    ];
  };
}
