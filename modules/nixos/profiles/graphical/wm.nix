{
  pkgs,
  lib,
  config,
  ...
}: let
  inherit (lib) mkIf;

  sddmTheme = pkgs.sddm-astronaut.override {
    embeddedTheme = "japanese_aesthetic";
    themeConfig = {
    };
  };
in {
  config = mkIf config.bosun.profiles.graphical.enable {
    environment.systemPackages = with pkgs; [
      wayland-utils
      wl-clipboard
      # libsForQt5.qtstyleplugin-kvantum
      nautilus
      sddmTheme
      kdePackages.qtmultimedia # required for our sddm theme
    ];

    programs.hyprland.enable = true;

    services = {
      xserver = {
        enable = true;
        displayManager.setupCommands = ''
          /run/current-system/sw/bin/xrandr --output HDMI-A-1 --primary
          /run/current-system/sw/bin/xrandr --output DP-3 --right-of HDMI-A-1 --rotate left
        '';
      };

      displayManager = {
        defaultSession = "hyprland";

        sddm = let
          theme = "sddm-astronaut-theme";
        in {
          enable = true;
          package = pkgs.kdePackages.sddm;

          # wayland.enable = true;

          inherit theme;
          extraPackages = [sddmTheme];
          settings.Theme.Current = theme;
        };
      };
    };

    xdg.portal = {
      enable = true;
      # xdgOpenUsePortal = true;
      config = {
        common.default = "gtk";
        hyprland.default = ["hyprland" "gtk"];
      };

      extraPortals = with pkgs; [
        xdg-desktop-portal-gnome
        xdg-desktop-portal-gtk
        xdg-desktop-portal-hyprland
      ];
    };

    security.polkit.enable = true;
  };
}
