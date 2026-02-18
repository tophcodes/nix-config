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
      nomad-auth = {
        description = "Fetches the Nomad management token from alvin. Pass --ui to also open the authenticated UI.";
        body = ''
          set -gx NOMAD_TOKEN (ssh root@alvin cat /var/lib/nomad-acl/management.token)
          if contains -- --ui $argv
            nomad ui -authenticate
          end
        '';
      };
      agx = {
        wraps = "ag";
        description = "Runs ag on the given string and returns a list of selectable references of the result. The selection is then opened in the editor.";
        body = ''
          hx (ag $search $argv[2..] | fzf | cut -d : -f 1,2)
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
    };

    preferAbbrs = true;
    shellAbbrs = {
      "elm" = "elements";

      # Git related
      "ga" = "git add";
      "gb" = "git branch";
      "gst" = "git status";
      "gbl" = "git blame";
      "grs" = "git restore --staged";
      "gcm" = "git commit -m \"%\"";

      "iso-date" = "date -u +\"%Y-%m-%dT%H:%M:%SZ\"";

      "jf" = "sudo journalctl -f -u";
      "sys stat" = "systemctl status";
      "sys up" = "systemctl start";
      "sys down" = "systemctl stop";
      "sys re" = "systemctl restart";
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
