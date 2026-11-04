_: {
  # One `hl.window_rule` per table: `match` holds the props a window must have,
  # every other field is an effect.
  wayland.windowManager.hyprland.settings.window_rule = [
    # Prevent garbage frame flash before first render
    {
      match.class = ".*";
      immediate = true;
    }

    # 1Password: floating, centered, reasonable size, blocked from screen
    # capture
    {
      match.class = "^(1password)$";
      float = true;
      center = true;
      size = "960 640";
      no_screen_share = true;
    }

    # Privacy: block from screen capture
    {
      match.class = "^(thunderbird)$";
      no_screen_share = true;
    }
    {
      match.title = "^(ld\\.toph\\.so)$";
      no_screen_share = true;
    }

    # The aleph overlay asks for a 160x32 always-on-top pill, which a Wayland
    # client cannot enforce. Without these it is tiled to half the screen and
    # reads as one big white window.
    {
      match.class = "^(aleph-desktop)$";
      float = true;
      size = "160 32";
      pin = true;
      border_size = 0;
    }

    # Floating windows
    {
      match.class = "^(org\\.zealdocs\\.zeal)$";
      float = true;
      center = true;
      size = "monitor_w*0.43 monitor_h*0.54";
      min_size = "1400 500";
      opacity = "0.93 0.90";
      rounding = 12;
      dim_around = true;
    }
    {
      match.class = "^(be\\.alexandervanhee\\.gradia)$";
      float = true;
      center = true;
      size = "monitor_w*0.58 monitor_h*0.58";
    }
    {
      match.class = "^(qalculate-gtk)$";
      float = true;
      center = true;
      size = "monitor_w*0.3 monitor_h*0.6";
      opacity = "0.93 0.90";
      rounding = 12;
      dim_around = true;
    }
    {
      match.title = "^(DevTools)$";
      float = true;
    }

    # steam-gamescope: Remote Play streams the window at its own size, so a
    # tiled 1884x1014 window reaches the TV letterboxed and upscaled.
    {
      match.class = "^(gamescope)$";
      float = true;
      size = "1920 1080";
      center = true;
    }

    # Noctalia Settings
    {
      match.class = "^(dev\\.noctalia\\.Noctalia\\.Settings)$";
      float = true;
      center = true;
      size = "1744 1354";
    }

    # Vertical monitor (DP-3): the notes vault on the half of pair 1, Slack on
    # the half of pair 2. Other chat apps open wherever they are launched.
    {
      match.class = "^(md\\.obsidian\\.Obsidian)$";
      workspace = "11 silent";
    }
    {
      match.class = "^([Ss]lack)$";
      workspace = "12 silent";
    }

    # Unreal Editor -> HDMI-A-1 (the 4K panel). The title matcher exempts
    # menus: Slate builds context menus and tooltips as their own toplevels
    # carrying class UnrealEditor with an empty title, and a monitor rule on
    # the bare class drags them off the cursor onto the other output.
    {
      match = {
        class = "^(UnrealEditor)$";
        title = ".+";
      };
      monitor = "HDMI-A-1";
    }

    # Fullscreen (mode 1 / maximize): thicker red border
    {
      match.fullscreen = true;
      border_size = 6;
      border_color = "rgb(e67e80)";
    }

    # Firefox fullscreen on left monitor (DP-3, workspaces 11-18): fake it.
    # fullscreen_state is a static rule and doesn't react to the client's
    # live fullscreen request, so Hyprland still took over the whole
    # monitor. suppress_event drops that request entirely (window stays
    # tiled); Firefox still hides its chrome since that's driven by its
    # own fullscreen API, independent of the compositor's ack.
    # class is `firefox.*` because each profile now launches with its own
    # `--name firefox-<profile>` (see below).
    {
      match = {
        class = "^(firefox.*)$";
        workspace = "r[11-18]";
      };
      suppress_event = "fullscreen";
    }

    # Firefox profiles -> dedicated workspaces. Each profile launches with
    # `--name firefox-<profile>` (keybinds.nix, firefox-with-context,
    # firefox-profiles desktop entries) so it gets its own class here.
    {
      match.class = "^(firefox-default)$";
      workspace = "1 silent";
    }
    {
      match.class = "^(firefox-work)$";
      workspace = "2 silent";
    }
    {
      match.class = "^(firefox-prune)$";
      workspace = "5 silent";
    }

    # JetBrains: suppress phantom windows (RE2 doesn't support lookaheads,
    # so we can't exclude toolbox here; apply per-IDE if needed)
    # { match = { class = "^(jetbrains-idea|jetbrains-rider|jetbrains-clion)$"; float = true; title = "^win\\d+$"; }; no_focus = true; }
  ];
}
