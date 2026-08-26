{
  inputs,
  lib,
  pkgs,
  ...
}: let
  picker = inputs.self.packages.${pkgs.stdenv.hostPlatform.system}.hyprland-preview-share-picker;
in {
  home.packages = [picker];

  # xdg-desktop-portal-hyprland takes its own settings from this file, not from
  # the session's hyprland.conf. The picker replaces the stock Qt list dialog
  # with GTK4 cards showing live window and monitor previews.
  xdg.configFile."hypr/xdph.conf".text = ''
    screencopy {
      custom_picker_binary = ${lib.getExe picker}
    }
  '';
}
