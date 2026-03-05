{
  lib,
  pkgs,
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

    shellAliases = config.home.shellAliases;
    shellInit = ''
      # Set global environment variables.
      ${env}
    '';

    functions = {
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
      "elm" = {
        expansion = "elements";
        tip = "Quick access to elements justfile";
      };

      # Git related
      "ga" = {expansion = "git add"; tip = "Stage files";};
      "gaa" = {expansion = "git add --all"; tip = "Stage all changes";};
      "gap" = {expansion = "git add --patch"; tip = "Interactively stage hunks";};
      "gb" = {expansion = "git branch"; tip = "List/manage branches";};
      "gst" = {expansion = "git status"; tip = "Show working tree status";};
      "gbl" = {expansion = "git blame"; tip = "Show who changed each line";};
      "grs" = {expansion = "git restore --staged"; tip = "Unstage files";};
      "gcm" = {expansion = "git commit -m \"%\""; tip = "Commit with message";};
      "gca" = {expansion = "git commit --amend"; tip = "Amend last commit";};
      "gcan" = {expansion = "git commit --amend --no-edit"; tip = "Amend without editing message";};
      "gco" = {expansion = "git checkout"; tip = "Switch branches (old style)";};
      "gcob" = {expansion = "git checkout -b"; tip = "Create and switch branch";};
      "gd" = {expansion = "git diff"; tip = "Show unstaged changes";};
      "gds" = {expansion = "git diff --staged"; tip = "Show staged changes";};
      "gl" = {expansion = "git log --oneline --graph"; tip = "Pretty git history";};
      "gp" = {expansion = "git push"; tip = "Push to remote";};
      "gpf" = {expansion = "git push --force-with-lease"; tip = "Safe force push";};
      "gpl" = {expansion = "git pull"; tip = "Pull from remote";};
      "gsw" = {expansion = "git switch"; tip = "Switch branches (new style)";};
      "gswc" = {expansion = "git switch -c"; tip = "Create and switch branch (new style)";};

      # System
      "iso-date" = {expansion = "date -u +\"%Y-%m-%dT%H:%M:%SZ\""; tip = "Get ISO 8601 timestamp";};
      "jf" = {expansion = "sudo journalctl -f -u"; tip = "Follow systemd journal";};
      "sys stat" = {expansion = "systemctl status"; tip = "Check service status";};
      "sys up" = {expansion = "systemctl start"; tip = "Start service";};
      "sys down" = {expansion = "systemctl stop"; tip = "Stop service";};
      "sys re" = {expansion = "systemctl restart"; tip = "Restart service";};

      # Quick navigation
      "infra" = {expansion = "cd /srv/infra"; tip = "Jump to infrastructure config";};
      "dots" = {expansion = "cd /srv/dotfiles"; tip = "Jump to dotfiles";};
      "code" = {expansion = "cd ~/code"; tip = "Jump to code directory";};
      "docs" = {expansion = "cd ~/documents"; tip = "Jump to documents";};

      # Positional expansions
      "-C" = {
        position = "anywhere";
        expansion = "--color";
      };
      "--np" = {
        position = "anywhere";
        function = "__np_expand";
      };
    };
  };
}
