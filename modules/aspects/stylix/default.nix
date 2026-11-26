{
  # Stylix theming, with the base16 palette handed on to noctalia and kitty.
  flake.modules.homeManager.stylix = {imports = [./_home.nix];};
}
