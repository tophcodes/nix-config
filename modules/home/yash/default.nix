# yash (YAzi-SHell) — tmux session pairing a yazi instance with a shell,
# kept in sync via yazi's DDS (ya emit-to).
#
#   shell → yazi: automatic, per-shell PWD hook emits a cd to the yazi pane
#   yazi → shell: <C-s> in yazi types a cd into the shell pane
#
# Sync hooks are installed for every enabled shell. `yash [shell-cmd]`
# spawns a specific shell in the right pane (default: login shell).
{
  pkgs,
  config,
  lib,
  ...
}: {
  config = lib.mkMerge [
    {
      home.packages = [
        (pkgs.writeShellApplication {
          name = "yash";
          runtimeInputs = [pkgs.tmux];
          text = builtins.readFile ./scripts/yash.sh;
        })
      ];

      # Leading space keeps the typed cd out of shell history.
      programs.yazi.keymap.mgr.prepend_keymap = [
        {
          on = "<C-s>";
          run = ''shell 'tmux send-keys -t yash.1 " cd \"$PWD\"" Enter' '';
          desc = "Sync shell pane to yazi cwd";
        }
      ];
    }

    (lib.mkIf config.programs.fish.enable {
      programs.fish.functions._yash_sync = {
        onVariable = "PWD";
        body = builtins.readFile ./scripts/sync-pwd.fish;
      };
    })

    (lib.mkIf config.programs.nushell.enable {
      # mkAfter: must run after any wholesale `$env.config = {...}` assignment.
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
