{
  # Kitty, behind its own `elements.kitty.enable` switch.
  flake.modules.homeManager.kitty = {imports = [./_home.nix];};
}
