_: {
  wayland.windowManager.hyprland.settings = {
    # Hyprland 0.55 windowrule v3: windowrulev2 is deprecated; matchers use
    # `match:<prop>`, boolean rules take on/off, several fields are snake_case
    # (border_size, min_size, border_color, no_screen_share, dim_around).
    windowrule = [
      # Prevent garbage frame flash before first render
      "immediate on, match:class .*"

      # 1Password: floating, centered, reasonable size
      "float on, match:class ^(1password)$"
      "center 1, match:class ^(1password)$"
      "size 960 640, match:class ^(1password)$"

      # Privacy: block from screen capture
      "no_screen_share on, match:class ^(1password)$"
      "no_screen_share on, match:class ^(thunderbird)$"
      "no_screen_share on, match:title ^(ld\\.toph\\.so)$"

      # The aleph overlay asks for a 160x32 always-on-top pill, which a Wayland
      # client cannot enforce. Without these it is tiled to half the screen and
      # reads as one big white window.
      "float on, match:class ^(aleph-desktop)$"
      "size 160 32, match:class ^(aleph-desktop)$"
      "pin on, match:class ^(aleph-desktop)$"
      "border_size 0, match:class ^(aleph-desktop)$"

      # Floating windows
      "float on, match:class ^(org\\.zealdocs\\.zeal)$"
      "center 1, match:class ^(org\\.zealdocs\\.zeal)$"
      "size 43% 54%, match:class ^(org\\.zealdocs\\.zeal)$"
      "min_size 1400 500, match:class ^(org\\.zealdocs\\.zeal)$"
      "opacity 0.93 0.90, match:class ^(org\\.zealdocs\\.zeal)$"
      "rounding 12, match:class ^(org\\.zealdocs\\.zeal)$"
      "dim_around on, match:class ^(org\\.zealdocs\\.zeal)$"

      "float on, match:class ^(be\\.alexandervanhee\\.gradia)$"
      "center 1, match:class ^(be\\.alexandervanhee\\.gradia)$"
      "size 58% 58%, match:class ^(be\\.alexandervanhee\\.gradia)$"

      "float on, match:class ^(qalculate-gtk)$"
      "center 1, match:class ^(qalculate-gtk)$"
      "size 30% 60%, match:class ^(qalculate-gtk)$"
      "opacity 0.93 0.90, match:class ^(qalculate-gtk)$"
      "rounding 12, match:class ^(qalculate-gtk)$"
      "dim_around on, match:class ^(qalculate-gtk)$"

      "float on, match:title ^(DevTools)$"

      # Noctalia Settings
      "float on, match:class ^(dev\\.noctalia\\.Noctalia\\.Settings)$"
      "center 1, match:class ^(dev\\.noctalia\\.Noctalia\\.Settings)$"
      "size 1744 1354, match:class ^(dev\\.noctalia\\.Noctalia\\.Settings)$"

      # Vertical monitor (DP-3): the notes vault on the half of pair 1, Slack on
      # the half of pair 2. Other chat apps open wherever they are launched.
      "workspace 11 silent, match:class ^(md\\.obsidian\\.Obsidian)$"
      "workspace 12 silent, match:class ^([Ss]lack)$"

      # Unreal Editor -> HDMI-A-1 (the 4K panel). The title matcher is
      # load-bearing: Slate builds context menus and tooltips as their own
      # toplevels carrying class UnrealEditor with an empty title, and a
      # monitor rule on the bare class drags them off the cursor onto the
      # other output.
      "monitor HDMI-A-1, match:class ^(UnrealEditor)$ match:title .+"

      # Fullscreen (mode 1 / maximize): thicker red border
      "border_size 6, match:fullscreen 1"
      "border_color rgb(e67e80), match:fullscreen 1"

      # Firefox fullscreen on left monitor (DP-3, workspaces 11-18): fake it.
      # fullscreen_state is a static rule and doesn't react to the client's
      # live fullscreen request, so Hyprland still took over the whole
      # monitor. suppress_event drops that request entirely (window stays
      # tiled); Firefox still hides its chrome since that's driven by its
      # own fullscreen API, independent of the compositor's ack. Field is
      # `suppress_event` (snake_case v3 field). `suppressevent` is the old
      # windowrulev2 keyword and errors here with "invalid field type".
      # class is `firefox.*` because each profile now launches with its own
      # `--name firefox-<profile>` (see below).
      "suppress_event fullscreen, match:class ^(firefox.*)$ match:workspace 11"
      "suppress_event fullscreen, match:class ^(firefox.*)$ match:workspace 12"
      "suppress_event fullscreen, match:class ^(firefox.*)$ match:workspace 13"
      "suppress_event fullscreen, match:class ^(firefox.*)$ match:workspace 14"
      "suppress_event fullscreen, match:class ^(firefox.*)$ match:workspace 15"
      "suppress_event fullscreen, match:class ^(firefox.*)$ match:workspace 16"
      "suppress_event fullscreen, match:class ^(firefox.*)$ match:workspace 17"
      "suppress_event fullscreen, match:class ^(firefox.*)$ match:workspace 18"

      # Firefox profiles -> dedicated workspaces. Each profile launches with
      # `--name firefox-<profile>` (keybinds.nix, firefox-with-context,
      # firefox-profiles desktop entries) so it gets its own class here.
      "workspace 1 silent, match:class ^(firefox-default)$"
      "workspace 2 silent, match:class ^(firefox-work)$"
      "workspace 5 silent, match:class ^(firefox-prune)$"

      # JetBrains: suppress phantom windows (RE2 doesn't support lookaheads,
      # so we can't exclude toolbox here; apply per-IDE if needed)
      # "no_focus on, match:class ^(jetbrains-idea|jetbrains-rider|jetbrains-clion)$, match:floating 1, match:title ^win\\d+$"
    ];
  };
}
