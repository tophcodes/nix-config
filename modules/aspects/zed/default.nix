{config, ...}: let
  # Bound out here on purpose: the home-manager module below shadows `config`
  # with its own, where `flake.lib` does not exist.
  inherit (config.flake.lib) aspects;
in {
  flake.modules.homeManager.zed = {pkgs, ...}: {
    imports = [
      (aspects.mkSymlinks {".config/zed" = ./config;})
    ];

    # Deliberately not `programs.zed-editor`: that module renders
    # `zed/settings.json` from Nix (ADR-016 rejects this for config Zed also
    # writes), and it would collide with the directory link above.
    home.packages = [
      pkgs.zed-editor
      # The Nix extension declares both `nil` and `nixd` and starts every
      # server it finds on PATH. nixd is here because only it evaluates the
      # flake, which is what completes `bosun.*` and home-manager option
      # names; settings.json disables nil so diagnostics are not doubled.
      pkgs.nixd
      pkgs.alejandra
    ];
  };
}
