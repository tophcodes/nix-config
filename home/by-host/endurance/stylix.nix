{
  inputs,
  pkgs,
  ...
}: {
  imports = [inputs.stylix.homeModules.stylix];

  home.packages = with pkgs; [
    # themes firefox with wallpaper theme
    pywalfox-native
  ];

  stylix = {
    enable = true;
    autoEnable = true;

    # TODO: Figure out a way for automatic dark-/light-mode switching
    # I've tried:
    # rose-pine-dawn
    # rose-pine-moon
    # ayu-mirage
    base16Scheme = "${pkgs.base16-schemes}/share/themes/everforest-dark-hard.yaml";

    targets = {
      gtk.enable = false;
      qt.enable = false;
      firefox.profileNames = ["default" "work" "streaming"];
      kitty.variant256Colors = true;
    };

    opacity.terminal = 0.92;

    cursor = {
      package = pkgs.rose-pine-cursor;
      # name = "Rosé Pine Dawn";
      name = "BreezeX-RosePine-Linux";
      size = 32;
    };
  };
}
