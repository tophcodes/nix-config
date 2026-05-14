{pkgs, ...}: {
  imports = [
    ./settings.nix
    ./keybinds.nix
    ./window-rules.nix
    ./wallpaper.nix
  ];

  wayland.windowManager.hyprland = {
    enable = true;
    plugins = with pkgs.hyprlandPlugins; [hyprbars hyprspace hypr-darkwindow];
  };

  home.packages = with pkgs; [
    wl-clipboard
    cliphist
    hyprpicker
  ];
}
