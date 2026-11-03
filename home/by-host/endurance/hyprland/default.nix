{pkgs, ...}: {
  imports = [
    ./settings.nix
    ./keybinds.nix
    ./window-rules.nix
    ./idle.nix
    ./share-picker.nix
  ];

  wayland.windowManager.hyprland = {
    enable = true;
    # Hyprland 0.57 reads only hyprland.lua. Stated explicitly because the
    # default follows home.stateVersion, which is still 25.11 here.
    configType = "lua";
    # The session binary + portal come from NixOS `programs.hyprland` (which
    # registers the wayland-session that SDDM reads). HM only writes config;
    # null prevents a second, divergent Hyprland in the profile.
    package = null;
    portalPackage = null;
    # No plugins: hyprspace only supports Hyprland up to 0.55 and no longer
    # compiles against 0.56 (nixpkgs #443989). Re-add once it builds.
  };

  home.packages = with pkgs; [
    wl-clipboard
    cliphist
    hyprpicker
  ];
}
