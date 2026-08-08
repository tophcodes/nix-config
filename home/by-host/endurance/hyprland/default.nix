{pkgs, ...}: {
  imports = [
    ./settings.nix
    ./keybinds.nix
    ./window-rules.nix
    ./wallpaper.nix
    ./idle.nix
  ];

  wayland.windowManager.hyprland = {
    enable = true;
    # The session binary + portal come from NixOS `programs.hyprland` (which
    # registers the wayland-session that SDDM reads). HM only writes config and
    # ships plugins — null prevents a second, divergent Hyprland in the profile.
    package = null;
    portalPackage = null;
    # hyprspace is dropped: upstream only supports Hyprland up to 0.55, and it
    # no longer compiles against 0.56 (nixpkgs #443989). Re-add once it builds.
    plugins = with pkgs.hyprlandPlugins; [hyprbars hypr-darkwindow];
  };

  home.packages = with pkgs; [
    wl-clipboard
    cliphist
    hyprpicker
  ];
}
