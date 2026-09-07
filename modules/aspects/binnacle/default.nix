# binnacle, a Quickshell instance beside noctalia.
#
# noctalia owns the bar and the notifications; this instance owns surfaces that
# are opened deliberately. It runs as a daemon so a widget that has to live
# permanently has somewhere to live, and so opening one costs no startup.
#
# Sheets are read from two directories at open time: `sheets/` holds the
# hand-written ones linked out of store, `generated/` holds what other modules
# render (the Hyprland binds come from the host's Hyprland config).
{config, ...}: let
  inherit (config.flake.lib) aspects;
in {
  flake.modules.homeManager.binnacle = {pkgs, ...}: let
    # The widget cannot glob a directory on its own, and a sheet that fails to
    # parse must not take the others down with it.
    sheets = pkgs.writeShellApplication {
      name = "binnacle-sheets";
      runtimeInputs = [pkgs.jq];
      text = ''
        shopt -s nullglob
        for f in "$HOME"/.config/binnacle/sheets/*.json "$HOME"/.config/binnacle/generated/*.json; do
          jq -c . "$f" || echo "binnacle: skipping unparsable sheet $f" >&2
        done | jq -s 'sort_by(.order // 100, .title)'
      '';
    };
  in {
    imports = [
      (aspects.mkSymlinks {
        ".config/quickshell/binnacle" = ./config/qml;
        ".config/binnacle/sheets" = ./config/sheets;
      })
    ];

    home.packages = [pkgs.quickshell sheets];

    systemd.user.services.binnacle = {
      Unit = {
        Description = "binnacle Quickshell instance";
        PartOf = ["graphical-session.target"];
        After = ["graphical-session.target"];
      };
      Service = {
        Type = "simple";
        # The QML side reads the loader from the environment rather than PATH,
        # which the unit does not inherit from an interactive shell.
        Environment = ["BINNACLE_SHEETS=${sheets}/bin/binnacle-sheets"];
        ExecStart = "${pkgs.quickshell}/bin/qs -c binnacle";
        Restart = "on-failure";
        RestartSec = "5s";
      };
      Install.WantedBy = ["graphical-session.target"];
    };
  };
}
