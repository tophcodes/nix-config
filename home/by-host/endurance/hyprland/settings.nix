# Each top-level attribute renders as one `hl.<name>(...)` call per list
# element; `config` is `hl.config({...})`. An `_args` list renders as a
# multi-argument call.
{lib, ...}: let
  inherit (lib.generators) mkLuaInline toLua;

  autostart = [
    # Clipboard history
    "wl-paste --type text --watch cliphist store"
    "wl-paste --type image --watch cliphist store"
    # Automount USB drives
    "udiskie"
    # Shell
    "noctalia"
    # KDE Connect: starts kdeconnectd via dbus + tray indicator
    "kdeconnect-indicator"
    # Notes vault (~/pod), placed on workspace 11 by a window rule
    "obsidian"
  ];
in {
  wayland.windowManager.hyprland.settings = {
    monitor = [
      # Main display (right)
      {
        output = "HDMI-A-1";
        mode = "3840x2160";
        position = "0x0";
        scale = 1;
      }
      # Vertical display (left)
      {
        output = "DP-3";
        mode = "1920x1080";
        position = "-1080x-50";
        scale = 1;
        transform = 3;
      }
      # Fallback for any other monitor
      {
        output = "";
        mode = "preferred";
        position = "auto";
        scale = 1;
      }
    ];

    on._args = [
      "hyprland.start"
      (mkLuaInline "function()\n${lib.concatMapStrings (cmd: "  hl.exec_cmd(${toLua {} cmd})\n") autostart}end")
    ];

    env = lib.mapAttrsToList (name: value: {_args = [name value];}) {
      MOZ_ENABLE_WAYLAND = "1";
      QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
      ELECTRON_OZONE_PLATFORM_HINT = "auto";
      NIXOS_OZONE_WL = "1";
      XDG_SESSION_TYPE = "wayland";
      XDG_CURRENT_DESKTOP = "Hyprland";
    };

    config = {
      input = {
        kb_layout = "us";
        kb_variant = "intl";
        follow_mouse = 2;
        sensitivity = 0;
      };

      general = {
        gaps_in = 12;
        gaps_out = 20;
        border_size = 2;
        layout = "dwindle";
      };

      decoration = {
        rounding = 8;
        blur.enabled = false;
        shadow.enabled = false;
      };

      animations.enabled = true;

      dwindle = {
        # `pseudotile` option removed in Hyprland 0.55; the `pseudo` dispatcher
        # (bound in keybinds.nix) toggles it per-window instead.
        preserve_split = true;
      };

      misc = {
        disable_hyprland_logo = true;
        disable_splash_rendering = true;
      };
    };

    curve._args = [
      "myBezier"
      {
        type = "bezier";
        points = [[0.05 0.9] [0.1 1.05]];
      }
    ];

    animation = [
      {
        leaf = "windows";
        enabled = true;
        speed = 7;
        bezier = "myBezier";
      }
      {
        leaf = "windowsOut";
        enabled = true;
        speed = 7;
        bezier = "default";
        style = "popin 80%";
      }
      {
        leaf = "border";
        enabled = true;
        speed = 10;
        bezier = "default";
      }
      {
        leaf = "fade";
        enabled = true;
        speed = 7;
        bezier = "default";
      }
      {
        leaf = "workspaces";
        enabled = true;
        speed = 6;
        bezier = "default";
      }
    ];

    workspace_rule =
      # Workspace N is a pair across both panels: N on HDMI-A-1, N+10 on DP-3.
      # keybinds.nix switches both halves together.
      lib.concatMap (n: let
        default = lib.optionalAttrs (n == 1) {default = true;};
      in [
        ({
            workspace = toString n;
            monitor = "HDMI-A-1";
          }
          // default)
        ({
            workspace = toString (n + 10);
            monitor = "DP-3";
          }
          // default)
      ]) (lib.range 1 8);
    # Single tiled window on main monitor: give it breathing room
    # { workspace = "w[t1] m[HDMI-A-1]"; gaps_out = "15 840 15 840"; }

    layer_rule = [
      # Vicinae launcher (wlr-layer-shell). Match upstream's recommended
      # quickstart rules: blur the launcher, skip slide-in animation.
      {
        match.namespace = "vicinae";
        blur = true;
        ignore_alpha = 0;
        no_anim = true;
        dim_around = true;
      }
    ];
  };
}
