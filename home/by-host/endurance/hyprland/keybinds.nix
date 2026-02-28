{pkgs, ...}: {
  wayland.windowManager.hyprland.settings = {
    "$mod" = "SUPER";

    bind = [
      # Apps
      "$mod, space, exec, fuzzel"
      "$mod, c, exec, ${pkgs.harbor.spawn-term}/bin/spawn-term"
      "$mod, e, exec, nautilus"
      "$mod, d, exec, zeal"
      "$mod, g, exec, ${pkgs.harbor.hg-picker}/bin/hg-picker"
      "$mod, v, exec, cliphist list | fuzzel --dmenu | cliphist decode | wl-copy"

      # Window management
      "$mod, q, killactive"
      "$mod, f, fullscreen, 1"
      "$mod, t, togglefloating"
      "$mod, p, pseudo"
      "$mod SHIFT, j, togglesplit"

      # Focus (vim-style, matching niri keybinds)
      "$mod, h, movefocus, l"
      "$mod, l, movefocus, r"
      "$mod, k, movefocus, u"
      "$mod, j, movefocus, d"

      # Move windows
      "$mod CTRL, h, movewindow, l"
      "$mod CTRL, l, movewindow, r"
      "$mod CTRL, k, movewindow, u"
      "$mod CTRL, j, movewindow, d"

      # Workspaces
      "$mod, 1, workspace, 1"
      "$mod, 2, workspace, 2"
      "$mod, 3, workspace, 3"
      "$mod, 4, workspace, 4"
      "$mod, 5, workspace, 5"

      # Move to workspace silently
      "$mod CTRL, 1, movetoworkspacesilent, 1"
      "$mod CTRL, 2, movetoworkspacesilent, 2"
      "$mod CTRL, 3, movetoworkspacesilent, 3"
      "$mod CTRL, 4, movetoworkspacesilent, 4"
      "$mod CTRL, 5, movetoworkspacesilent, 5"
    ];

    bindm = [
      # Mouse: move and resize windows
      "$mod, mouse:272, movewindow"
      "$mod, mouse:273, resizewindow"
    ];

    bindl = [
      # Scroll through workspaces
      "$mod, mouse_down, workspace, e+1"
      "$mod, mouse_up, workspace, e-1"
    ];
  };
}
