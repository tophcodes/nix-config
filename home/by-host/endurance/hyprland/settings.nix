{lib, ...}: {
  wayland.windowManager.hyprland.settings = {
    monitor = [
      # Main display (right)
      "HDMI-A-1,3840x2160,0x0,1"
      # Vertical display (left)
      "DP-3,1920x1080,-1080x-50,1,transform,3"
      # Fallback for any other monitor
      ",preferred,auto,1"
    ];

    exec-once = [
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

    env = [
      "MOZ_ENABLE_WAYLAND,1"
      "QT_WAYLAND_DISABLE_WINDOWDECORATION,1"
      "ELECTRON_OZONE_PLATFORM_HINT,auto"
      "NIXOS_OZONE_WL,1"
      "XDG_SESSION_TYPE,wayland"
      "XDG_CURRENT_DESKTOP,Hyprland"
    ];

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

    animations = {
      enabled = true;
      bezier = "myBezier, 0.05, 0.9, 0.1, 1.05";
      animation = [
        "windows, 1, 7, myBezier"
        "windowsOut, 1, 7, default, popin 80%"
        "border, 1, 10, default"
        "fade, 1, 7, default"
        "workspaces, 1, 6, default"
      ];
    };

    workspace =
      # Workspace N is a pair across both panels: N on HDMI-A-1, N+10 on DP-3.
      # keybinds.nix switches both halves together.
      lib.concatMap (n: [
        "${toString n}, monitor:HDMI-A-1${lib.optionalString (n == 1) ", default:true"}"
        "${toString (n + 10)}, monitor:DP-3${lib.optionalString (n == 1) ", default:true"}"
      ]) (lib.range 1 8);
    # Single tiled window on main monitor: give it breathing room
    # "w[t1] m[HDMI-A-1], gapsout:15 840 15 840"

    dwindle = {
      # `pseudotile` option removed in Hyprland 0.55; the `pseudo` dispatcher
      # (bound in keybinds.nix) toggles it per-window instead.
      preserve_split = true;
    };

    layerrule = [
      # Vicinae launcher (wlr-layer-shell). Match upstream's recommended
      # quickstart rules: blur the launcher, skip slide-in animation.
      # Hyprland 0.55 layerrule v3: boolean rules take on/off, matcher is match:.
      "blur on, match:namespace vicinae"
      "ignore_alpha 0, match:namespace vicinae"
      "no_anim on, match:namespace vicinae"
      "dim_around on, match:namespace vicinae"
    ];

    misc = {
      disable_hyprland_logo = true;
      disable_splash_rendering = true;
    };
  };
}
