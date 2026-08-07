{
  lib,
  config,
  ...
}: let
  # Extract tips from shell abbreviations
  abbrTips = lib.pipe config.programs.fish.shellAbbrs [
    (lib.filterAttrs (_name: value:
        (lib.isAttrs value) && (value ? tip)))
    (lib.mapAttrsToList (name: value: "'${name} → ${value.tip}'"))
  ];

  # Function tips from descriptions
  functionTips = lib.pipe config.programs.fish.functions [
    (lib.filterAttrs (_name: value: value ? description))
    (lib.mapAttrsToList (name: value: "'${name} → ${value.description}'"))
  ];

  # Hyprland keybind tips (manually curated for now)
  hyprlandTips = [
    "'Mod+e → Open yazi file manager'"
    "'Mod+b → Open Firefox'"
    "'Mod+[/] → Switch workspaces'"
    "'Mod+Tab → Cycle windows'"
    "'Mod+s → Scratchpad toggle'"
    "'Mod+Shift+c → Open Claude'"
    "'Mod+=/- → Resize windows'"
    "'Mod+hjkl → Navigate windows'"
    "'Mod+f → Fullscreen'"
    "'Mod+t → Toggle floating'"
    "'Mod+q → Close window'"
  ];

  # Firefox/Tridactyl tips
  browserTips = [
    "'f → Link hints (click with keyboard)'"
    "'hjkl → Scroll in Firefox'"
    "'JK → Switch tabs'"
    "'x/X → Close/restore tab'"
    "'H/L → Back/forward'"
    "'o/O → Open URL/new tab'"
  ];

  allTips = abbrTips ++ functionTips ++ hyprlandTips ++ browserTips;

  # Generate Fish code to store tips
  tipsArray = lib.concatStringsSep " \\\n          " allTips;
in {
  programs.fish.interactiveShellInit = ''
    # MOTD: Show a random shortcut tip
    function __fish_motd --on-event fish_prompt --once
      set -l tips ${tipsArray}

      if test (count $tips) -gt 0
        set -l random_tip $tips[(random 1 (count $tips))]
        echo (set_color yellow)"💡 Tip:"(set_color normal) $random_tip
        echo (set_color brblack)"   (Type 'shortcuts' to see all)"(set_color normal)
      end
    end
  '';
}
