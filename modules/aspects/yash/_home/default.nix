# yash (YAzi-SHell): tmux session pairing a yazi instance with a shell,
# kept in sync via yazi's DDS (ya emit-to).
#
#   shell → yazi: automatic, per-shell PWD hook emits a cd to the yazi pane
#   yazi → shell: <C-s> calls yash-cd which targets the shell pane by stored ID
#   Alt+y: cycles yazi pane through hidden → dir (25%) → multi (45%) → full (zoom)
#
# Sync hooks are installed for every enabled shell.
{
  pkgs,
  config,
  lib,
  ...
}: let
  mkYashPkg = name: script: extraInputs: extraArgs:
    pkgs.writeShellApplication ({
        inherit name;
        runtimeInputs = [pkgs.tmux] ++ extraInputs;
        text = builtins.readFile script;
      }
      // extraArgs);
in {
  config = lib.mkMerge [
    {
      home.packages = [
        (mkYashPkg "yash" ./scripts/yash.sh [] {runtimeEnv.YASH_TMUX_CONF = ./scripts/yash.tmux.conf;})
        (mkYashPkg "yash-toggle" ./scripts/yash-toggle.sh [] {})
        (mkYashPkg "yash-cd" ./scripts/yash-cd.sh [] {})
      ];

      programs.yazi = {
        settings.mgr.mouse_events = ["click" "scroll"];

        keymap.mgr.prepend_keymap = [
          {
            on = "<C-s>";
            run = ''shell 'yash-cd "$PWD"' '';
            desc = "Sync shell pane to yazi cwd";
          }
        ];
      };
    }

    (lib.mkIf config.programs.fish.enable {
      programs.fish.functions._yash_sync = {
        onVariable = "PWD";
        body = builtins.readFile ./scripts/sync-pwd.fish;
      };
    })

    (lib.mkIf config.programs.nushell.enable {
      programs.nushell.extraConfig = lib.mkAfter (builtins.readFile ./scripts/sync-pwd.nu);
    })

    (lib.mkIf config.programs.bash.enable {
      programs.bash.initExtra = builtins.readFile ./scripts/sync-pwd.bash;
    })

    (lib.mkIf config.programs.zsh.enable {
      programs.zsh.initContent = builtins.readFile ./scripts/sync-pwd.zsh;
    })
  ];
}
