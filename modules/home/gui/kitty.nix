{
  config,
  pkgs,
  lib,
  ...
}:
with lib; let
  cfg = config.elements;
in {
  options = {
    elements.kitty = {
      enable = mkEnableOption "kitty";
    };
  };

  config = mkIf cfg.kitty.enable {
    programs.fish.enable = true;
    programs.kitty = {
      enable = true;

      settings = {
        cursor_trail = "1";
        window_padding_width = "3 3";
        paste_actions = "no-op";
        # font_family = "Monaspace Neon NF";

        # Transparency (opacity controlled by Stylix)
        background_blur = "32";
        dynamic_background_opacity = true;
      };

      actionAliases = {
        "launch_current" = "launch --cwd current";
      };

      extraConfig = ''
        shell ${pkgs.fish}/bin/fish
        # modify_font cell_height 7px
      '';
    };

    xdg.configFile."kitty/open-actions.conf".text = ''
      # ~/pod is the Obsidian vault, and a pod.toph.so URL path is the vault
      # path, so a clicked note belongs in Obsidian rather than the browser.
      # Addressed by absolute path: a second, unregistered .obsidian directory
      # lives under the vault, which makes the vault name ambiguous.
      # Limitation: ''${FILE_PATH} is unquoted, so a path containing spaces
      # produces a broken URI. Encode in a wrapper script if that ever happens.
      protocol https
      url ^https://pod\.toph\.so/.+\.md$
      action launch --type=background ${pkgs.xdg-utils}/bin/xdg-open obsidian://open?path=/home/toph/pod''${FILE_PATH}

      # Open all file links in helix in the current shell
      protocol file
      # mime text/*
      action send_text normal,application hx "''${FILE_PATH}"\r
    '';
  };
}
