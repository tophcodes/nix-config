{pkgs, ...}: {
  imports = [
    ./settings.nix
    ./keybinds.nix
    ./window-rules.nix
    ./wallpaper.nix
  ];

  wayland.windowManager.hyprland = {
    enable = true;
    # The session binary + portal come from NixOS `programs.hyprland` (which
    # registers the wayland-session that SDDM reads). HM only writes config and
    # ships plugins — null prevents a second, divergent Hyprland in the profile.
    package = null;
    portalPackage = null;
    plugins = with pkgs.hyprlandPlugins; [hyprbars hyprspace hypr-darkwindow];
  };

  home.packages = with pkgs; [
    wl-clipboard
    cliphist
    hyprpicker
  ];
}
