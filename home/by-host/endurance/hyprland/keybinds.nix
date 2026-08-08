{pkgs, ...}: {
  wayland.windowManager.hyprland.settings = {
    "$mod" = "SUPER";

    bind = [
      # Apps
      "$mod, space, exec, vicinae toggle"
      "$mod, c, exec, kitty --directory \"$(focused-checkout)\""
      "$mod, e, exec, kitty --directory \"$(focused-checkout)\" yazi"
      "$mod, d, exec, zeal"
      "$mod, g, exec, ${pkgs.harbor.hg-picker}/bin/hg-picker"
      "$mod, v, exec, vicinae vicinae://launch/clipboard/history"
      "$mod, b, exec, firefox -P default --name firefox-default"
      "$mod, n, exec, noctalia msg notification-dnd-toggle"
      "$mod, m, exec, checkout-menu"
      "$mod, r, exec, voxtype record start"
      # Session capture, as opposed to hold-to-dictate above: starts writing to
      # the transcript inbox, and the second press asks before it ends.
      "$mod SHIFT, r, exec, voxtype-capture toggle"
      "$mod SHIFT, m, exec, voxtype-capture meeting"
      "$mod SHIFT, e, exec, kitty --directory \"$(focused-checkout)\" hx"

      # Window management
      "$mod, q, killactive"
      "$mod, f, fullscreen, 1"
      "$mod, t, togglefloating"
      "$mod, p, pseudo"
      "$mod SHIFT, j, layoutmsg, togglesplit"

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
      "$mod, 6, workspace, 6"
      "$mod, 7, workspace, 7"
      "$mod, 8, workspace, 8"

      # Move window to workspace (stay on current)
      "$mod SHIFT, 1, movetoworkspacesilent, 1"
      "$mod SHIFT, 2, movetoworkspacesilent, 2"
      "$mod SHIFT, 3, movetoworkspacesilent, 3"
      "$mod SHIFT, 4, movetoworkspacesilent, 4"
      "$mod SHIFT, 5, movetoworkspacesilent, 5"
      "$mod SHIFT, 6, movetoworkspacesilent, 6"
      "$mod SHIFT, 7, movetoworkspacesilent, 7"
      "$mod SHIFT, 8, movetoworkspacesilent, 8"

      # Cycle through workspaces with keyboard
      "$mod, bracketright, workspace, e+1"
      "$mod, bracketleft, workspace, e-1"

      # Tab through windows
      "$mod, tab, cyclenext"
      "$mod SHIFT, tab, cyclenext, prev"

      # Resize windows with keyboard
      "$mod, equal, resizeactive, 50 0"
      "$mod, minus, resizeactive, -50 0"
      "$mod SHIFT, equal, resizeactive, 0 50"
      "$mod SHIFT, minus, resizeactive, 0 -50"

      # Special workspace (scratchpad)
      "$mod, s, togglespecialworkspace, magic"
      "$mod SHIFT, s, movetoworkspace, special:magic"

      # Center floating window
      "$mod, o, centerwindow"
    ];

    # Push-to-talk dictation: hold to record, release to transcribe at the
    # cursor. Needs the release half below, so it cannot live in `bind`.
    bindr = [
      "$mod, r, exec, voxtype record stop"
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
