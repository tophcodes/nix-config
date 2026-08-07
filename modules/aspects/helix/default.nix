{config, ...}: let
  inherit (config.flake.lib) aspects;
in {
  flake.modules.homeManager.helix = {lib, ...}: {
    # Files rather than the directory: stylix writes themes/stylix.toml into
    # the same directory, and home-manager cannot write into a linked working
    # copy. Safe here because Helix never rewrites its own config — the
    # atomic-rename hazard that forces directory links elsewhere needs an
    # application that writes.
    imports = [
      (aspects.mkSymlinks {
        ".config/helix/config.toml" = ./config/config.toml;
        ".config/helix/languages.toml" = ./config/languages.toml;
      })
    ];

    programs.helix = {
      enable = true;
      defaultEditor = true;

      # Emptied so home-manager writes neither config.toml nor languages.toml
      # — it renders each only when its attrset is non-empty, and both are
      # linked above. The module stays enabled because stylix hangs
      # themes/stylix.toml off it, which is genuinely computed from the colour
      # scheme; the linked config.toml references it by name.
      settings = lib.mkForce {};
      languages = lib.mkForce {};
    };
  };
}
