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

  # kitty watches the directory holding each included config file, and recurses
  # into it. The Stylix kitty target includes its theme by a bare store path,
  # making that directory /nix/store itself — hundreds of thousands of inotify
  # watches per kitty instance. That target is therefore off below, and the
  # identical theme is re-exported into a directory of its own so a single file
  # gets watched. The font and opacity settings replace what it would set.
  #
  # Narrowing programs.kitty.extraConfig with mkForce is not an alternative:
  # home-manager feeds settings, font and actionAliases through that same
  # option, so any override priority discards those along with the include.
  kittyTheme =
    pkgs.runCommand "kitty-theme" {}
    ''
      mkdir -p $out
      cp ${c {
        templateRepo = inputs.stylix.inputs.tinted-kitty;
        target = "base16";
      }} $out/theme.conf
    '';
in {
  imports = [inputs.stylix.homeModules.stylix];

  home.packages = with pkgs; [
    # themes firefox with wallpaper theme
    pywalfox-native
  ];

  xdg.configFile."noctalia/palettes/stylix.json".source = noctaliaBase16Palette;

  programs.kitty = {
    font = {
      inherit (config.stylix.fonts.monospace) package name;
      size = config.stylix.fonts.sizes.terminal;
    };

    settings.background_opacity = toString config.stylix.opacity.terminal;

    extraConfig = ''
      include ${kittyTheme}/theme.conf
    '';
  };

  stylix = {
    enable = true;
    autoEnable = true;

    # TODO: Figure out a way for automatic dark-/light-mode switching
    # I've tried:
    # rose-pine-dawn
    # rose-pine-moon
    # ayu-mirage
    # da-one-white
    base16Scheme = {
      system = "base16";
      name = "vague";
      author = "vague2k";
      variant = "dark";
      palette = {
        base00 = "141415"; # bg
        base01 = "1c1c24"; # inactiveBg
        base02 = "252530"; # line / selection
        base03 = "606079"; # comment
        base04 = "878787"; # floatBorder
        base05 = "cdcdcd"; # fg
        base06 = "c3c3d5"; # property
        base07 = "aeaed1"; # constant
        base08 = "d8647e"; # error
        base09 = "e8b589"; # string (warm beige-orange)
        base0A = "f3be7c"; # warning / yellow
        base0B = "7fa563"; # plus / green
        base0C = "b4d4cf"; # builtin / cyan-teal
        base0D = "7e98e8"; # hint / blue (functions)
        base0E = "bb9dbd"; # parameter / purple (keywords)
        base0F = "6e94b2"; # keyword / steel-blue
      };
    };

    targets = {
      gtk.enable = false;
      qt.enable = true;
      firefox.profileNames = ["default" "work" "streaming"];
      kitty.enable = false;
      kitty.variant256Colors = true;
      # noctalia keeps its own builtin theme. The stylix target would force
      # `theme.source = "custom"` plus a generated palette, and derives
      # `theme.mode` from the (unset, hence light) polarity.
      noctalia.enable = false;
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
