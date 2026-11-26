{
  description = "toph's workstation: home-manager and NixOS modules for a Hyprland desktop";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    # herdr-core and herdr-desktop need helpers only nixpkgs master has.
    master.url = "github:NixOS/nixpkgs/master";

    flake-parts.url = "github:hercules-ci/flake-parts";
    import-tree.url = "github:vic/import-tree";
    devkit = {
      url = "github:tophcodes/devkit";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-parts.follows = "flake-parts";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    stylix = {
      url = "github:nix-community/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    noctalia = {
      url = "github:noctalia-dev/noctalia";
      inputs.nixpkgs.follows = "unstable";
    };
    musnix.url = "github:musnix/musnix";
    tuicr.url = "github:agavra/tuicr";
    bootvine = {
      url = "git+https://codeberg.org/wvhulle/bootvine";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  # `flakeModules.default` carries everything another flake imports. The files
  # under nix/ belong to this repository alone: its tooling and the example
  # configurations its checks evaluate.
  outputs = inputs @ {flake-parts, ...}:
    flake-parts.lib.mkFlake {inherit inputs;} ({self, ...}: let
      default = {
        imports = [
          (inputs.import-tree ./modules/flake)
          # `config/` holds each aspect's payload: data, never modules.
          (inputs.import-tree.matchNot ".*/config/.*" ./modules/aspects)
        ];

        # Out-of-store links from these aspects resolve against this working
        # copy, whichever flake imports them.
        checkouts.${builtins.unsafeDiscardStringContext (toString self)} = "/home/toph/code/nix-config";
      };
    in {
      imports = [
        inputs.flake-parts.flakeModules.flakeModules
        inputs.flake-parts.flakeModules.modules
        default
        (inputs.import-tree ./nix)
      ];

      flake.flakeModules = {inherit default;};
    });
}
