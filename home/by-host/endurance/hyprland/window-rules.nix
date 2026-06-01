_: {
  wayland.windowManager.hyprland.settings = {
    windowrulev2 = [
      # Prevent garbage frame flash before first render
      "immediate, class:.*"

      # Privacy: block from screen capture
      "noscreenshare, class:^(1password)$"
      "noscreenshare, class:^(thunderbird)$"
      "noscreenshare, title:^(ld\\.toph\\.so)$"

      # Floating windows
      "float, class:^(org\\.zealdocs\\.zeal)$"
      "center 1, class:^(org\\.zealdocs\\.zeal)$"
      "size 43% 54%, class:^(org\\.zealdocs\\.zeal)$"
      "minsize 1400 500, class:^(org\\.zealdocs\\.zeal)$"
      "opacity 0.93 0.90, class:^(org\\.zealdocs\\.zeal)$"
      "rounding 12, class:^(org\\.zealdocs\\.zeal)$"
      "dimaround, class:^(org\\.zealdocs\\.zeal)$"

      "float, class:^(be\\.alexandervanhee\\.gradia)$"
      "center 1, class:^(be\\.alexandervanhee\\.gradia)$"
      "size 58% 58%, class:^(be\\.alexandervanhee\\.gradia)$"

      "float, class:^(qalculate-gtk)$"
      "center 1, class:^(qalculate-gtk)$"
      "size 30% 60%, class:^(qalculate-gtk)$"
      "opacity 0.93 0.90, class:^(qalculate-gtk)$"
      "rounding 12, class:^(qalculate-gtk)$"
      "dimaround, class:^(qalculate-gtk)$"

      "float, title:^(DevTools)$"

      # Messaging apps -> left vertical monitor (DP-3, workspace 6)
      "workspace 6 silent, class:^([Ss]lack)$"
      "workspace 6 silent, class:^(vesktop)$"
      "workspace 6 silent, class:^([Ss]ignal)$"
      "workspace 6 silent, class:^([Ww]asistlos)$"

      # Kitty: slight transparency
      "opacity 0.97 0.97, class:^(kitty)$"

      # Fullscreen (mode 1 / maximize): thicker red border
      "bordersize 6, fullscreen:1"
      "bordercolor rgb(e67e80), fullscreen:1"

      # Only show hyprbars on kitty windows
      "plugin:hyprbars:nobar, class:negative:^(kitty)$"

      # JetBrains: suppress phantom windows (RE2 doesn't support lookaheads,
      # so we can't exclude toolbox here — apply per-IDE if needed)
      # "nofocus, class:^(jetbrains-idea|jetbrains-rider|jetbrains-clion)$, floating:1, title:^win\\d+$"
    ];
  };
}
