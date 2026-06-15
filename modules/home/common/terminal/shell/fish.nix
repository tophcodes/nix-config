{
  lib,
  config,
  ...
}: let
  env =
    lib.concatMapAttrsStringSep
    "\n"
    (name: value: "set -gx ${name} ${lib.escapeShellArg value}")
    config.home.sessionVariables;
in {
  programs.fish = {
    enable = true;

    inherit (config.home) shellAliases;
    shellInit = ''
      # Set global environment variables.
      ${env}
    '';

    functions = {
      fish_title = {
        description = "Window title with SSH host context";
        body = ''
          set -l prefix ""
          if set -q SSH_CONNECTION
            set prefix (prompt_hostname)": "
          end

          set -l cmd (status current-command)
          if test "$cmd" = fish
            echo "$prefix"(prompt_pwd)
          else
            echo "$prefix$cmd"
          end
        '';
      };
      __np_expand = {
        description = "Expands --np contextually: --pp for bat/cat, --no-pager otherwise";
        body = ''
          set -l cmd (commandline -po)[1]
          if test "$cmd" = bat -o "$cmd" = cat
            echo -- --pp
          else
            echo -- --no-pager
          end
        '';
      };
      rgf = {
        description = "Ripgrep with fuzzy file selection - opens result in helix";
        body = ''
          set -l result (rg --line-number --color=always $argv | fzf --ansi)
          if test -n "$result"
            set -l file (echo $result | cut -d: -f1)
            set -l line (echo $result | cut -d: -f2)
            hx "$file:$line"
          end
        '';
      };
      ff = {
        description = "Fuzzy find file and open in helix";
        body = ''
          set -l file (fd --type f | fzf)
          if test -n "$file"
            hx "$file"
          end
        '';
      };
      ghpr = {
        description = "Interactive gh pr view/checkout";
        body = ''
          gh pr list | fzf | awk '{print $1}' | xargs -I {} gh pr checkout {}
        '';
      };
      nt = {
        description = "nix run ~/code/tools#<tool> [args]";
        body = ''
          nix run ~/code/tools#$argv[1] -- $argv[2..]
        '';
      };
      ",man" = {
        description = "man page for a nixpkgs tool (comma-style, on demand)";
        body = ''
          if test -z "$argv[1]"
            echo "usage: ,man <tool> [man args]" >&2
            return 1
          end
          nix shell "nixpkgs#$argv[1]" --command man $argv[2..] $argv[1]
        '';
      };
      screenshot = {
        description = "Take a screenshot: region (default) or full screen, then open in gradia";
        body = ''
          switch $argv[1]
            case --help -h
              echo "usage: screenshot [full|window] [-h|--help]"
              echo ""
              echo "  (no args)  select region → gradia"
              echo "  full       full screen → gradia"
              echo "  window     click a window → gradia"
            case full
              grim - | gradia
            case window
              set -l region (hyprctl clients -j | jq -r '.[] | "\(.at[0]),\(.at[1]) \(.size[0])x\(.size[1])"' | slurp)
              if test $status -ne 0
                echo "selection cancelled" >&2
                return 1
              end
              grim -g $region - | gradia
            case '*'
              set -l region (slurp)
              if test $status -ne 0
                echo "selection cancelled" >&2
                return 1
              end
              grim -g $region - | gradia
          end
        '';
      };
      record = {
        description = "Screen recording: 'record' starts, 'record stop' stops";
        body = ''
          switch $argv[1]
            case --help -h
              echo "usage: record [stop] [-h|--help]"
              echo ""
              echo "  (no args)  start recording"
              echo "  stop       stop recording"
            case stop
              noctalia msg screen-recorder stop
            case '*'
              noctalia msg screen-recorder start
          end
        '';
      };
      shortcuts = {
        description = "Show all aliases, abbreviations, and functions";
        body = ''
          set -l items

          # Get abbreviations
          for line in (abbr --show)
            set -l parts (string match -r '^abbr -a -- (\S+) (.+)$' $line)
            if test (count $parts) -ge 3
              set -a items "abbr: $parts[2] → $parts[3]"
            end
          end

          # Get functions
          for func_name in (functions -n | string match -v -r '^_')
            set func_desc (functions -D -v $func_name)
            if test -n "$func_desc"
              set -a items "func: $func_name - $func_desc"
            else
              set -a items "func: $func_name"
            end
          end

          # Fuzzy search through all items
          printf '%s\n' $items | fzf --height 40% --reverse --prompt "shortcuts> "
        '';
      };
    };

    preferAbbrs = true;
    shellAbbrs = {
      "elm" = "elements";

      # Git related
      "ga" = "git add";
      "gaa" = "git add --all";
      "gap" = "git add --patch";
      "gb" = "git branch";
      "gst" = "git status";
      "gbl" = "git blame";
      "grs" = "git restore --staged";
      "gcm" = "git commit -m \"%\"";
      "gca" = "git commit --amend";
      "gcan" = "git commit --amend --no-edit";
      "gco" = "git checkout";
      "gcob" = "git checkout -b";
      "gd" = "git diff";
      "gds" = "git diff --staged";
      "gl" = "git log --oneline --graph";
      "gp" = "git push";
      "gpf" = "git push --force-with-lease";
      "gpl" = "git pull";
      "gsw" = "git switch";
      "gswc" = "git switch -c";

      # System
      "iso-date" = "date -u +\"%Y-%m-%dT%H:%M:%SZ\"";
      "jf" = "sudo journalctl -f -u";
      "sys stat" = "systemctl status";
      "sys up" = "systemctl start";
      "sys down" = "systemctl stop";
      "sys re" = "systemctl restart";

      # Quick navigation
      "docs" = "cd ~/documents";

      # Positional expansions
      "-C" = {
        position = "anywhere";
        expansion = "--color";
      };
      "--np" = {
        position = "anywhere";
        function = "__np_expand";
      };
      "--danger" = {
        position = "anywhere";
        command = "claude";
        expansion = "--dangerously-skip-permissions";
      };
    };
  };
}
