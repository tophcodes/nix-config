_: {
  wayland.windowManager.hyprland.settings = {
    # Hyprland 0.55 windowrule v3: windowrulev2 is deprecated; matchers use
    # `match:<prop>`, boolean rules take on/off, several fields are snake_case
    # (border_size, min_size, border_color, no_screen_share, dim_around).
    windowrule = [
      # Prevent garbage frame flash before first render
      "immediate on, match:class .*"

      # Privacy: block from screen capture
      "no_screen_share on, match:class ^(1password)$"
      "no_screen_share on, match:class ^(thunderbird)$"
      "no_screen_share on, match:title ^(ld\\.toph\\.so)$"

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

      # Messaging apps -> left vertical monitor (DP-3, workspace 6)
      "workspace 6 silent, match:class ^([Ss]lack)$"
      "workspace 6 silent, match:class ^(vesktop)$"
      "workspace 6 silent, match:class ^([Ss]ignal)$"
      "workspace 6 silent, match:class ^([Ww]asistlos)$"

      # Kitty: slight transparency
      "opacity 0.97 0.97, match:class ^(kitty)$"

      # Fullscreen (mode 1 / maximize): thicker red border
      "border_size 6, match:fullscreen 1"
      "border_color rgb(e67e80), match:fullscreen 1"

      # JetBrains: suppress phantom windows (RE2 doesn't support lookaheads,
      # so we can't exclude toolbox here — apply per-IDE if needed)
      # "no_focus on, match:class ^(jetbrains-idea|jetbrains-rider|jetbrains-clion)$, match:floating 1, match:title ^win\\d+$"
    ];
  };
}
