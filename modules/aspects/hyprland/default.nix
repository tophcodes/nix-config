{
  # Hyprland's user configuration: settings, keybinds with their cheat sheet,
  # window rules, idle handling and the screen-share picker. The session itself
  # comes from the NixOS side (`programs.hyprland` in the graphical aspect).
  flake.modules.homeManager.hyprland = {imports = [./_home];};
}
