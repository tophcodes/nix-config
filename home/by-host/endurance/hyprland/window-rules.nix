{...}: {
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
      "size 50% 80%, class:^(org\\.zealdocs\\.zeal)$"
      "minsize 1400 500, class:^(org\\.zealdocs\\.zeal)$"

      "float, class:^(speedcrunch)$"
      "center 1, class:^(speedcrunch)$"
      "size 30% 60%, class:^(speedcrunch)$"

      "float, title:^(DevTools)$"

      # Kitty: slight transparency
      "opacity 0.97 0.97, class:^(kitty)$"

      # JetBrains: suppress phantom windows (RE2 doesn't support lookaheads,
      # so we can't exclude toolbox here — apply per-IDE if needed)
      # "nofocus, class:^(jetbrains-idea|jetbrains-rider|jetbrains-clion)$, floating:1, title:^win\\d+$"
    ];
  };
}
