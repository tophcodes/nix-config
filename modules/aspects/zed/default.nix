{config, ...}: let
  # Bound out here on purpose: the home-manager module below shadows `config`
  # with its own, where `flake.lib` does not exist.
  inherit (config.flake.lib) repoPath;
in {
  flake.modules.homeManager.zed = {
    config,
    pkgs,
    ...
  }: {
    home.packages = [pkgs.zed-editor];

    # Deliberately not `programs.zed-editor`: that module renders
    # `zed/settings.json` from Nix (ADR-016 rejects this for config Zed also
    # writes), and it would collide with this directory link.
    xdg.configFile."zed".source =
      config.lib.file.mkOutOfStoreSymlink (repoPath ./config);
  };
}
