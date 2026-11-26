{inputs, ...}: {
  imports = [inputs.devkit.flakeModules.default];

  systems = ["x86_64-linux"];

  # The package set packages/ builds against. A flake importing
  # `flakeModules.default` supplies its own and has to provide the same two
  # extras.
  perSystem = {
    system,
    pkgs,
    ...
  }: {
    devkit.packages = [pkgs.watchexec];

    _module.args.pkgs = import inputs.nixpkgs {
      inherit system;
      # diversion ships under an unfree licence.
      config.allowUnfreePredicate = pkg: builtins.elem (inputs.nixpkgs.lib.getName pkg) ["diversion"];
      overlays = [
        (_final: _prev: {
          # For packages whose dependency graph declares a rust-version past
          # the stable channel's rustc; cargo treats that as a hard error.
          rustPlatformUnstable = (import inputs.unstable {inherit system;}).rustPlatform;
        })
      ];
    };
  };
}
