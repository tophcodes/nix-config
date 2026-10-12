# The graphical session: Hyprland under SDDM, with the portals a Wayland
# desktop needs to talk to GTK and Qt applications.
{
  flake.modules.nixos.graphical = {pkgs, ...}: let
    sddmTheme = pkgs.sddm-astronaut.override {
      embeddedTheme = "japanese_aesthetic";
      themeConfig = {
      };
    };
  in {
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
        hyprland = {
          default = ["hyprland" "gtk"];
          # darkman answers only color-scheme; gtk still serves every other
          # setting. Earlier entries win for a key both report.
          "org.freedesktop.impl.portal.Settings" = ["darkman" "gtk"];
        };
      };

      extraPortals = with pkgs; [
        darkman
        xdg-desktop-portal-gnome
        xdg-desktop-portal-gtk
        xdg-desktop-portal-hyprland
      ];
    };

    security.polkit.enable = true;
  };
}
