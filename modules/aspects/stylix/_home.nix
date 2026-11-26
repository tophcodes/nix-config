{
  inputs,
  pkgs,
  config,
  ...
}: let
  c = config.lib.stylix.colors;
  h = s: "#${s}";
  noctaliaBase16Palette = pkgs.writeText "stylix.json" (builtins.toJSON {
    primary = h c.base0D;
    on_primary = h c.base00;
    primary_container = h c.base01;
    on_primary_container = h c.base04;
    primary_fixed_dim = h c.base0D;
    inverse_primary = h c.base0D;
    secondary = h c.base0E;
    on_secondary = h c.base00;
    secondary_container = h c.base01;
    on_secondary_container = h c.base04;
    secondary_fixed_dim = h c.base0E;
    tertiary = h c.base0C;
    on_tertiary = h c.base00;
    tertiary_container = h c.base01;
    on_tertiary_container = h c.base04;
    tertiary_fixed_dim = h c.base0C;
    background = h c.base00;
    on_background = h c.base05;
    surface = h c.base00;
    on_surface = h c.base05;
    surface_variant = h c.base01;
    on_surface_variant = h c.base03;
    surface_bright = h c.base00;
    surface_dim = h c.base01;
    surface_container_lowest = h c.base00;
    surface_container_low = h c.base01;
    surface_container = h c.base01;
    surface_container_high = h c.base02;
    surface_container_highest = h c.base02;
    inverse_surface = h c.base05;
    inverse_on_surface = h c.base00;
    surface_tint = h c.base0D;
    error = h c.base08;
    on_error = h c.base00;
    error_container = h c.base01;
    on_error_container = h c.base08;
    outline = h c.base02;
    outline_variant = h c.base01;
    scrim = h c.base06;
    shadow = h c.base06;
    neutral = h c.base02;
    neutral_variant = h c.base03;
  });

  # kitty follows the portal's color-scheme on its own: it reads these three
  # files from its config directory and swaps between them live. They come
  # from a directory of their own because kitty watches the directory of each
  # file it loads, and a bare store path would make that /nix/store itself.
  #
  # kitty-themes' Alucard.conf is an unrelated dark scheme, so the light theme
  # is rendered from the Alucard palette below.
  kittyAutoThemes =
    pkgs.runCommand "kitty-auto-themes" {
      alucard = c {
        templateRepo = inputs.stylix.inputs.tinted-kitty;
        target = "base16";
      };
    } ''
      mkdir -p $out
      themes=${pkgs.kitty-themes}/share/kitty-themes/themes
      cp $themes/Dracula.conf $out/dark-theme.auto.conf
      cp $alucard $out/light-theme.auto.conf
      cp $alucard $out/no-preference-theme.auto.conf
    '';
in {
  imports = [inputs.stylix.homeModules.stylix];

  home.packages = with pkgs; [
    # themes firefox with wallpaper theme
    pywalfox-native
  ];

  programs.kitty = {
    font = {
      inherit (config.stylix.fonts.monospace) package name;
      size = config.stylix.fonts.sizes.terminal;
    };

    settings.background_opacity = toString config.stylix.opacity.terminal;
  };

  xdg.configFile = {
    "noctalia/palettes/stylix.json".source = noctaliaBase16Palette;
    "kitty/light-theme.auto.conf".source = "${kittyAutoThemes}/light-theme.auto.conf";
    "kitty/dark-theme.auto.conf".source = "${kittyAutoThemes}/dark-theme.auto.conf";
    "kitty/no-preference-theme.auto.conf".source = "${kittyAutoThemes}/no-preference-theme.auto.conf";
  };

  # Stylix keeps fonts, cursor and opacity. Colors come from each app's own
  # light/dark theme pair, switched live through darkman. The scheme below
  # feeds only the derivations in this repo that still read
  # config.lib.stylix.colors (the kitty and VS Code light themes, the noctalia
  # palette).
  stylix = {
    enable = true;
    autoEnable = false;

    # Alucard, from tinted-schemes base24/alucard.yaml. Inlined because
    # base16.nix fails to parse that file.
    base16Scheme = {
      system = "base16";
      name = "Alucard";
      author = "clach04";
      variant = "light";
      palette = {
        base00 = "fffbeb";
        base01 = "ceccc0";
        base02 = "cfcfde";
        base03 = "6c664b";
        base04 = "4c4a3d";
        base05 = "1f1f1f";
        base06 = "1f1f1f";
        base07 = "2c2b31";
        base08 = "cb3a2a";
        base09 = "a34d14";
        base0A = "846e15";
        base0B = "14710a";
        base0C = "036a96";
        base0D = "644ac9";
        base0E = "a3144d";
        base0F = "792219";
      };
    };
    polarity = "light";

    targets = {
      fontconfig.enable = true;
      font-packages.enable = true;
    };

    opacity.terminal = 1.0;

    cursor = {
      package = pkgs.rose-pine-cursor;
      # name = "Rosé Pine Dawn";
      name = "BreezeX-RosePine-Linux";
      size = 32;
    };
  };
}
