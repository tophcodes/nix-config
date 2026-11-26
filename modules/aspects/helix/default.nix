{config, ...}: let
  inherit (config.flake.lib) aspects;
in {
  flake.modules.homeManager.helix = {lib, ...}: {
    # Files rather than the directory. Safe here because Helix never rewrites
    # its own config. The atomic-rename hazard that forces directory links
    # elsewhere needs an application that writes.
    imports = [
      (aspects.mkSymlinks {
        ".config/helix/config.toml" = ./config/config.toml;
        ".config/helix/languages.toml" = ./config/languages.toml;
      })
    ];

    programs.helix = {
      enable = true;
      defaultEditor = true;

      # Emptied so home-manager writes neither config.toml nor languages.toml:
      # it renders each only when its attrset is non-empty, and both are
      # linked above. The module stays enabled for the package and
      # defaultEditor.
      settings = lib.mkForce {};
      languages = lib.mkForce {};
    };
  };
}
