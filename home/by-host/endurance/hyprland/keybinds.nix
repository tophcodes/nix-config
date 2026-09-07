# One record per bind. Hyprland gets `bindd` lines from them, binnacle gets a
# cheat sheet, and neither can drift from the other because both are rendered
# from this list.
#
# `flags` carries the Hyprland bind flags other than `d` (`r` release, `m`
# mouse, `l` locked). `sheet` is `false` for a bind the sheet should not list,
# or an attribute set overriding `keys` and `desc` for the one entry that
# stands in for a whole run of binds.
{
  pkgs,
  lib,
  ...
}: let
  # The first of a mechanical run carries the entry that stands in for all of
  # them; the rest stay off the sheet.
  sheetOrHidden = n: entry:
    if n == 1
    then {sheet = entry;}
    else {hidden = true;};

  workspaces = lib.concatMap (n: let
    s = toString n;
  in [
    ({
        group = "Workspaces";
        mods = "$mod";
        key = s;
        desc = "Workspace ${s}";
        action = "workspace, ${s}";
      }
      // sheetOrHidden n {
        keys = "SUPER + 1..8";
        desc = "Switch to workspace";
      })
    ({
        group = "Workspaces";
        mods = "$mod SHIFT";
        key = s;
        desc = "Move window to workspace ${s}";
        action = "movetoworkspacesilent, ${s}";
      }
      // sheetOrHidden n {
        keys = "SUPER + SHIFT + 1..8";
        desc = "Move window to workspace, stay here";
      })
  ]) (lib.range 1 8);

  binds =
    [
      # Apps
      {
        group = "Apps";
        mods = "$mod";
        key = "space";
        desc = "Launcher";
        action = "exec, vicinae toggle";
      }
      {
        group = "Apps";
        mods = "$mod";
        key = "c";
        desc = "Terminal in the focused checkout";
        action = "exec, kitty --directory \"$(focused-checkout)\"";
      }
      {
        group = "Apps";
        mods = "$mod";
        key = "e";
        desc = "File manager in the focused checkout";
        action = "exec, kitty --directory \"$(focused-checkout)\" yazi";
      }
      {
        group = "Apps";
        mods = "$mod SHIFT";
        key = "e";
        desc = "Editor in the focused checkout";
        action = "exec, kitty --directory \"$(focused-checkout)\" hx";
      }
      {
        group = "Apps";
        mods = "$mod";
        key = "b";
        desc = "Browser";
        action = "exec, firefox -P default --name firefox-default";
      }
      {
        group = "Apps";
        mods = "$mod";
        key = "v";
        desc = "Clipboard history";
        action = "exec, vicinae vicinae://launch/clipboard/history";
      }
      {
        group = "Apps";
        mods = "$mod";
        key = "m";
        desc = "Checkout menu";
        action = "exec, checkout-menu";
      }
      {
        group = "Apps";
        mods = "$mod";
        key = "g";
        desc = "Open a hausgold repository";
        action = "exec, ${pkgs.harbor.hg-picker}/bin/hg-picker";
      }
      {
        group = "Apps";
        mods = "$mod";
        key = "n";
        desc = "Toggle do not disturb";
        action = "exec, noctalia msg notification-dnd-toggle";
      }
      {
        group = "Apps";
        mods = "$mod";
        key = "slash";
        desc = "Cheat sheet";
        action = "exec, qs -c binnacle ipc call sheet toggle";
      }

      # Dictation. Both keys are push-to-talk, so each has a release half; the
      # release halves carry the same description and stay off the sheet.
      {
        group = "Dictation";
        mods = "$mod";
        key = "r";
        desc = "Transcribe at the cursor";
        action = "exec, voxtype record start";
        note = "hold";
      }
      {
        group = "Dictation";
        mods = "$mod";
        key = "r";
        desc = "Transcribe at the cursor";
        action = "exec, voxtype record stop";
        flags = "r";
        hidden = true;
      }
      {
        group = "Dictation";
        mods = "$mod";
        key = "d";
        desc = "Capture into the vault inbox";
        action = "exec, voxtype-capture dictate";
        note = "hold";
      }
      {
        group = "Dictation";
        mods = "$mod";
        key = "d";
        desc = "Capture into the vault inbox";
        action = "exec, voxtype-capture stop";
        flags = "r";
        hidden = true;
      }

      # Windows
      {
        group = "Windows";
        mods = "$mod";
        key = "q";
        desc = "Close window";
        action = "killactive";
      }
      {
        group = "Windows";
        mods = "$mod";
        key = "f";
        desc = "Maximise";
        action = "fullscreen, 1";
      }
      {
        group = "Windows";
        mods = "$mod";
        key = "t";
        desc = "Toggle floating";
        action = "togglefloating";
      }
      {
        group = "Windows";
        mods = "$mod";
        key = "p";
        desc = "Pseudo tile";
        action = "pseudo";
      }
      {
        group = "Windows";
        mods = "$mod";
        key = "o";
        desc = "Centre a floating window";
        action = "centerwindow";
      }
      {
        group = "Windows";
        mods = "$mod SHIFT";
        key = "j";
        desc = "Toggle split direction";
        action = "layoutmsg, togglesplit";
      }
      {
        group = "Windows";
        mods = "$mod";
        key = "equal";
        desc = "Widen";
        action = "resizeactive, 50 0";
      }
      {
        group = "Windows";
        mods = "$mod";
        key = "minus";
        desc = "Narrow";
        action = "resizeactive, -50 0";
      }
      {
        group = "Windows";
        mods = "$mod SHIFT";
        key = "equal";
        desc = "Taller";
        action = "resizeactive, 0 50";
      }
      {
        group = "Windows";
        mods = "$mod SHIFT";
        key = "minus";
        desc = "Shorter";
        action = "resizeactive, 0 -50";
      }

      # Focus, vim-style, matching the niri keybinds
      {
        group = "Focus";
        mods = "$mod";
        key = "h";
        desc = "Focus left";
        action = "movefocus, l";
      }
      {
        group = "Focus";
        mods = "$mod";
        key = "j";
        desc = "Focus down";
        action = "movefocus, d";
      }
      {
        group = "Focus";
        mods = "$mod";
        key = "k";
        desc = "Focus up";
        action = "movefocus, u";
      }
      {
        group = "Focus";
        mods = "$mod";
        key = "l";
        desc = "Focus right";
        action = "movefocus, r";
      }
      {
        group = "Focus";
        mods = "$mod CTRL";
        key = "h";
        desc = "Move window left";
        action = "movewindow, l";
      }
      {
        group = "Focus";
        mods = "$mod CTRL";
        key = "j";
        desc = "Move window down";
        action = "movewindow, d";
      }
      {
        group = "Focus";
        mods = "$mod CTRL";
        key = "k";
        desc = "Move window up";
        action = "movewindow, u";
      }
      {
        group = "Focus";
        mods = "$mod CTRL";
        key = "l";
        desc = "Move window right";
        action = "movewindow, r";
      }
      {
        group = "Focus";
        mods = "$mod";
        key = "tab";
        desc = "Next window";
        action = "cyclenext";
      }
      {
        group = "Focus";
        mods = "$mod SHIFT";
        key = "tab";
        desc = "Previous window";
        action = "cyclenext, prev";
      }
    ]
    ++ workspaces
    ++ [
      {
        group = "Workspaces";
        mods = "$mod";
        key = "bracketright";
        desc = "Next workspace";
        action = "workspace, e+1";
      }
      {
        group = "Workspaces";
        mods = "$mod";
        key = "bracketleft";
        desc = "Previous workspace";
        action = "workspace, e-1";
      }
      {
        group = "Workspaces";
        mods = "$mod";
        key = "mouse_down";
        desc = "Next workspace";
        action = "workspace, e+1";
        flags = "l";
        note = "scroll";
      }
      {
        group = "Workspaces";
        mods = "$mod";
        key = "mouse_up";
        desc = "Previous workspace";
        action = "workspace, e-1";
        flags = "l";
        note = "scroll";
      }

      # Scratchpad
      {
        group = "Scratchpad";
        mods = "$mod";
        key = "s";
        desc = "Toggle the scratchpad";
        action = "togglespecialworkspace, magic";
      }
      {
        group = "Scratchpad";
        mods = "$mod SHIFT";
        key = "s";
        desc = "Move window to the scratchpad";
        action = "movetoworkspace, special:magic";
      }

      # Mouse
      {
        group = "Mouse";
        mods = "$mod";
        key = "mouse:272";
        desc = "Move window";
        action = "movewindow";
        flags = "m";
        note = "drag";
      }
      {
        group = "Mouse";
        mods = "$mod";
        key = "mouse:273";
        desc = "Resize window";
        action = "resizewindow";
        flags = "m";
        note = "drag";
      }
    ];

  # Hyprland side: one attribute per flag combination, each holding its lines.
  bindLine = b: "${b.mods}, ${b.key}, ${b.desc}, ${b.action}";
  bindSettings = lib.mapAttrs (_: map bindLine) (lib.groupBy (b: "bindd" + (b.flags or "")) binds);

  # Sheet side. Key names Hyprland spells out get a printable form; everything
  # else is upper-cased, which covers letters and leaves digits alone.
  keyNames = {
    space = "Space";
    tab = "Tab";
    slash = "/";
    equal = "=";
    minus = "-";
    bracketleft = "[";
    bracketright = "]";
    mouse_up = "Wheel up";
    mouse_down = "Wheel down";
    "mouse:272" = "Left button";
    "mouse:273" = "Right button";
  };

  keyLabel = b:
    lib.concatStringsSep " + " (
      lib.splitString " " (lib.replaceStrings ["$mod"] ["SUPER"] b.mods)
      ++ [(keyNames.${b.key} or (lib.toUpper b.key))]
    );

  listed = lib.filter (b: !(b.hidden or false)) binds;

  entryOf = b: let
    override = b.sheet or {};
  in
    {
      keys = override.keys or (keyLabel b);
      desc = override.desc or b.desc;
    }
    // lib.optionalAttrs (b ? note) {inherit (b) note;};

  groups = map (name: {
    inherit name;
    entries = map entryOf (lib.filter (b: b.group == name) listed);
  }) (lib.unique (map (b: b.group) listed));

  sheet = pkgs.writeText "hyprland.json" (builtins.toJSON {
    title = "Hyprland";
    order = 10;
    inherit groups;
  });
in {
  wayland.windowManager.hyprland.settings = {"$mod" = "SUPER";} // bindSettings;

  home.file.".config/binnacle/generated/hyprland.json".source = sheet;
}
