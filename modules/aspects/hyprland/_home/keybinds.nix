# One record per bind. Hyprland gets `hl.bind` calls from them, binnacle gets
# a cheat sheet, and neither can drift from the other because both are
# rendered from this list.
#
# `action` is a Lua expression: a dispatcher, or a function the bind calls.
# `opts` carries the bind flags other than the description (`release`,
# `mouse`, `locked`). `sheet` is `false` for a bind the sheet should not list,
# or an attribute set overriding `keys` and `desc` for the one entry the sheet
# lists for a whole run of binds.
{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (lib.generators) mkLuaInline toLua;

  # The first of a mechanical run carries the sheet entry for the whole run;
  # the rest stay off the sheet.
  sheetOrHidden = n: entry:
    if n == 1
    then {sheet = entry;}
    else {hidden = true;};

  exec = cmd: "hl.dsp.exec_cmd(${toLua {} cmd})";

  # Calls `fn` from one of the Lua modules under ./lua (extraLuaFiles below).
  call = module: fn: "function() require(${toLua {} module}).${fn} end";

  workspaces = lib.concatMap (n: let
    s = toString n;
  in [
    ({
        group = "Workspaces";
        mods = "$mod";
        key = s;
        desc = "Workspace ${s}";
        action = call "workspace_pair" "switch(${s})";
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
        action = call "workspace_pair" "move(${s})";
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
        action = exec "vicinae toggle";
      }
      {
        group = "Apps";
        mods = "$mod";
        key = "c";
        desc = "Terminal in the focused checkout";
        action = exec "kitty --directory \"$(focused-checkout)\"";
      }
      {
        group = "Apps";
        mods = "$mod";
        key = "e";
        desc = "File manager in the focused checkout";
        action = exec "kitty --directory \"$(focused-checkout)\" yazi";
      }
      {
        group = "Apps";
        mods = "$mod SHIFT";
        key = "e";
        desc = "Editor in the focused checkout";
        action = exec "kitty --directory \"$(focused-checkout)\" hx";
      }
      {
        group = "Apps";
        mods = "$mod";
        key = "b";
        desc = "Browser";
        action = exec "firefox -P default --name firefox-default";
      }
      {
        group = "Apps";
        mods = "$mod";
        key = "v";
        desc = "Clipboard history";
        action = exec "vicinae vicinae://launch/clipboard/history";
      }
      {
        group = "Apps";
        mods = "$mod";
        key = "m";
        desc = "Checkout menu";
        action = exec "checkout-menu";
      }
      {
        group = "Apps";
        mods = "$mod";
        key = "n";
        desc = "Toggle do not disturb";
        action = exec "noctalia msg notification-dnd-toggle";
      }
      {
        group = "Apps";
        mods = "$mod SHIFT";
        key = "n";
        desc = "Notes";
        action = call "window_actions" "focus_notes()";
      }
      {
        group = "Apps";
        mods = "$mod";
        key = "slash";
        desc = "Cheat sheet";
        action = exec "qs -c binnacle ipc call sheet toggle";
      }

      # Dictation. Both keys are push-to-talk, so each has a release half; the
      # release halves carry the same description and stay off the sheet.
      {
        group = "Dictation";
        mods = "$mod";
        key = "r";
        desc = "Transcribe at the cursor";
        action = exec "voxtype record start";
        note = "hold";
      }
      {
        group = "Dictation";
        mods = "$mod";
        key = "r";
        desc = "Transcribe at the cursor";
        action = exec "voxtype record stop";
        opts.release = true;
        hidden = true;
      }
      {
        group = "Dictation";
        mods = "$mod";
        key = "d";
        desc = "Capture into the vault inbox";
        action = exec "voxtype-capture dictate";
        note = "hold";
      }
      {
        group = "Dictation";
        mods = "$mod";
        key = "d";
        desc = "Capture into the vault inbox";
        action = exec "voxtype-capture stop";
        opts.release = true;
        hidden = true;
      }

      # Windows
      {
        group = "Windows";
        mods = "$mod";
        key = "q";
        desc = "Close window";
        action = "hl.dsp.window.close()";
      }
      {
        group = "Windows";
        mods = "$mod";
        key = "f";
        desc = "Maximise";
        action = ''hl.dsp.window.fullscreen({ mode = "maximized" })'';
      }
      {
        group = "Windows";
        mods = "$mod";
        key = "t";
        desc = "Toggle floating";
        action = "hl.dsp.window.float()";
      }
      {
        group = "Windows";
        mods = "$mod";
        key = "p";
        desc = "Pseudo tile";
        action = "hl.dsp.window.pseudo()";
      }
      {
        group = "Windows";
        mods = "$mod SHIFT";
        key = "p";
        desc = "Pin to every workspace of this monitor";
        action = call "window_actions" "toggle_pin()";
      }
      {
        group = "Windows";
        mods = "$mod";
        key = "o";
        desc = "Centre a floating window";
        action = "hl.dsp.window.center()";
      }
      {
        group = "Windows";
        mods = "$mod SHIFT";
        key = "j";
        desc = "Toggle split direction";
        action = ''hl.dsp.layout("togglesplit")'';
      }
      {
        group = "Windows";
        mods = "$mod";
        key = "equal";
        desc = "Widen";
        action = "hl.dsp.window.resize({ x = 50, y = 0, relative = true })";
      }
      {
        group = "Windows";
        mods = "$mod";
        key = "minus";
        desc = "Narrow";
        action = "hl.dsp.window.resize({ x = -50, y = 0, relative = true })";
      }
      {
        group = "Windows";
        mods = "$mod SHIFT";
        key = "equal";
        desc = "Taller";
        action = "hl.dsp.window.resize({ x = 0, y = 50, relative = true })";
      }
      {
        group = "Windows";
        mods = "$mod SHIFT";
        key = "minus";
        desc = "Shorter";
        action = "hl.dsp.window.resize({ x = 0, y = -50, relative = true })";
      }

      # Focus, vim-style, matching the niri keybinds
      {
        group = "Focus";
        mods = "$mod";
        key = "h";
        desc = "Focus left";
        action = ''hl.dsp.focus({ direction = "left" })'';
      }
      {
        group = "Focus";
        mods = "$mod";
        key = "j";
        desc = "Focus down";
        action = ''hl.dsp.focus({ direction = "down" })'';
      }
      {
        group = "Focus";
        mods = "$mod";
        key = "k";
        desc = "Focus up";
        action = ''hl.dsp.focus({ direction = "up" })'';
      }
      {
        group = "Focus";
        mods = "$mod";
        key = "l";
        desc = "Focus right";
        action = ''hl.dsp.focus({ direction = "right" })'';
      }
      {
        group = "Focus";
        mods = "$mod CTRL";
        key = "h";
        desc = "Move window left";
        action = ''hl.dsp.window.move({ direction = "left" })'';
      }
      {
        group = "Focus";
        mods = "$mod CTRL";
        key = "j";
        desc = "Move window down";
        action = ''hl.dsp.window.move({ direction = "down" })'';
      }
      {
        group = "Focus";
        mods = "$mod CTRL";
        key = "k";
        desc = "Move window up";
        action = ''hl.dsp.window.move({ direction = "up" })'';
      }
      {
        group = "Focus";
        mods = "$mod CTRL";
        key = "l";
        desc = "Move window right";
        action = ''hl.dsp.window.move({ direction = "right" })'';
      }
      {
        group = "Focus";
        mods = "$mod";
        key = "tab";
        desc = "Next window";
        action = "hl.dsp.window.cycle_next()";
      }
      {
        group = "Focus";
        mods = "$mod SHIFT";
        key = "tab";
        desc = "Previous window";
        action = "hl.dsp.window.cycle_next({ next = false })";
      }
    ]
    ++ workspaces
    ++ [
      {
        group = "Workspaces";
        mods = "$mod";
        key = "bracketright";
        desc = "Next workspace";
        action = call "workspace_pair" "switch(\"next\")";
      }
      {
        group = "Workspaces";
        mods = "$mod";
        key = "bracketleft";
        desc = "Previous workspace";
        action = call "workspace_pair" "switch(\"prev\")";
      }
      {
        group = "Workspaces";
        mods = "$mod";
        key = "mouse_down";
        desc = "Next workspace";
        action = call "workspace_pair" "switch(\"next\")";
        opts.locked = true;
        note = "scroll";
      }
      {
        group = "Workspaces";
        mods = "$mod";
        key = "mouse_up";
        desc = "Previous workspace";
        action = call "workspace_pair" "switch(\"prev\")";
        opts.locked = true;
        note = "scroll";
      }

      # Scratchpad
      {
        group = "Scratchpad";
        mods = "$mod";
        key = "s";
        desc = "Toggle the scratchpad";
        action = ''hl.dsp.workspace.toggle_special("magic")'';
      }
      {
        group = "Scratchpad";
        mods = "$mod SHIFT";
        key = "s";
        desc = "Move window to the scratchpad";
        action = ''hl.dsp.window.move({ workspace = "special:magic" })'';
      }

      # Mouse
      {
        group = "Mouse";
        mods = "$mod";
        key = "mouse:272";
        desc = "Move window";
        action = "hl.dsp.window.drag()";
        opts.mouse = true;
        note = "drag";
      }
      {
        group = "Mouse";
        mods = "$mod";
        key = "mouse:273";
        desc = "Resize window";
        action = "hl.dsp.window.resize()";
        opts.mouse = true;
        note = "drag";
      }
    ]
    ++ config.fleet.hyprland.extraBinds;

  # `$mod` is SUPER; modifiers and the key join with " + ", the form both
  # Hyprland and the sheet use. `keyName` renders the key itself.
  keyCombo = keyName: b:
    lib.concatStringsSep " + " (
      lib.splitString " " (lib.replaceStrings ["$mod"] ["SUPER"] b.mods)
      ++ [(keyName b.key)]
    );

  bindCall = b: {
    _args = [
      (keyCombo lib.id b)
      (mkLuaInline b.action)
      ({description = b.desc;} // (b.opts or {}))
    ];
  };

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

  keyLabel = keyCombo (k: keyNames.${k} or (lib.toUpper k));

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
  options.fleet.hyprland.extraBinds = lib.mkOption {
    type = lib.types.listOf lib.types.attrs;
    default = [];
    description = "Further bind records in the format above, appended to the built-in ones.";
  };

  config.wayland.windowManager.hyprland = {
    settings.bind = map bindCall binds;

    extraLuaFiles = {
      workspace_pair.content = ./lua/workspace_pair.lua;
      window_actions.content = ./lua/window_actions.lua;
    };
  };

  config.home.file.".config/binnacle/generated/hyprland.json".source = sheet;
}
