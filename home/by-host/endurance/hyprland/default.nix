{pkgs, ...}: {
  imports = [
    ./settings.nix
    ./keybinds.nix
    ./window-rules.nix
  ];

  wayland.windowManager.hyprland.enable = true;

  home.packages = with pkgs; [
    wl-clipboard
    cliphist
    hyprpicker
  ];
}
