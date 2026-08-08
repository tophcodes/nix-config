{
  inputs,
  pkgs,
  ...
}: {
  imports = [
    inputs.niri.homeModules.niri

    ./settings.nix
    ./window-rules.nix
    ./keybinds.nix
    ./autostart.nix
    ./shell.nix
  ];

  # niri-flake's overlay asserts `libdisplay-info_0_2.version == "0.2.0"`, and
  # nixpkgs dropped that alias. Build niri from the flake's own pinned nixpkgs
  # instead of ours until upstream stops asserting on it.
  programs.niri.package = inputs.niri.packages.${pkgs.stdenv.hostPlatform.system}.niri-stable;

  home.packages = with pkgs; [
    wl-clipboard
    cliphist
  ];
}
