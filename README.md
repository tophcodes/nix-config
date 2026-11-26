# nix-config

The desktop half of my NixOS setup: home-manager and NixOS modules for a
Hyprland workstation, plus the packages they install. A private flake imports
this one and adds the servers, the services and the secrets.

## Layout

- `modules/aspects/<name>/` is one feature. Its `default.nix` is a
  [flake-parts](https://flake.parts) module that writes
  `flake.modules.homeManager.<name>`, `flake.modules.nixos.<name>` or both.
  A host gets the feature by importing that module; aspects have no `enable`
  option.
- `modules/aspects/<name>/config/` holds the files the application reads.
  home-manager links them out of the store into the working copy, so an edit
  takes effect without a rebuild and a setting the application writes lands
  in git.
- `packages/<name>/package.nix` is a package of the same name.
- `nix/` holds this repository's tooling and two example configurations,
  `homeConfigurations.example` and `nixosConfigurations.example`, which import
  every aspect. `nix flake check` evaluates both.

## Using it from another flake

```nix
{
  inputs.nix-config.url = "github:tophcodes/nix-config";

  outputs = inputs:
    inputs.flake-parts.lib.mkFlake {inherit inputs;} {
      imports = [
        inputs.flake-parts.flakeModules.modules
        inputs.nix-config.flakeModules.default
      ];
    };
}
```

The aspects then appear under the importing flake's own `self.modules`. They
read flake inputs by the names this flake uses (`stylix`, `noctalia`,
`devkit`, …), so the importing flake declares those inputs too.

Out-of-store links resolve against `/home/toph/code/nix-config`; the
`checkouts` option maps a flake's store path to its working copy.

## License

MIT, see [LICENSE](LICENSE).
