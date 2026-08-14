# noctalia, the Wayland shell.
#
# Two files in this repo describe it, and they are not the same kind of thing:
#
#   programs.noctalia.settings  — the seed. Rendered to config.toml and applied
#     only for keys the runtime state does not mention. On a machine that has
#     been used, that is the keys nobody ever touched in the GUI.
#   config/state/settings.toml  — a mirror of the runtime state, copied here by
#     the unit below and committed by dotfiles-sync. Never applied; it exists so
#     GUI changes have a history and show up in review.
#
# The asymmetry is forced: noctalia merges its state file over config.toml per
# key, so anything adjusted at runtime permanently shadows the declaration. The
# state file cannot simply be linked into the repo either — it sits beside
# plaintext credentials and clipboard history in the same directory.
{
  config,
  inputs,
  ...
}: let
  inherit (config.flake.lib) repoPath;
  mirror = repoPath ./config/state/settings.toml;
in {
  flake.modules.homeManager.noctalia = {pkgs, ...}: let
    syncMirror = pkgs.writeShellApplication {
      name = "noctalia-mirror-settings";
      runtimeInputs = with pkgs; [diffutils coreutils];
      text = ''
        state="$HOME/.local/state/noctalia/settings.toml"
        mirror=${mirror}

        # Nothing has run yet on a fresh machine; that is not an error.
        [ -f "$state" ] || exit 0

        if cmp -s "$state" "$mirror"; then
          exit 0
        fi

        cp "$state" "$mirror"
        echo "refreshed noctalia settings mirror"
      '';
    };
  in {
    imports = [inputs.noctalia.homeModules.default];

    programs.noctalia = {
      enable = true;
      settings = {
        shell = {
          font_family = "DejaVu Sans";
          telemetry_enabled = false;
          avatar_path = "~/.face";
          clipboard_auto_paste = "off";
          shadow.direction = "down_right";
          animation = {
            enabled = true;
            speed = 1.0;
          };
          panel.control_center_placement = "attached";
        };

        theme = {
          mode = "dark";
          source = "builtin";
          builtin = "Noctalia";
        };

        wallpaper = {
          enabled = false;
          directory = "~/Pictures/Wallpapers";
          transition = ["fade" "disc" "stripes" "wipe" "pixelate" "honeycomb"];
        };

        # A plugin loads only once its id is listed here, whatever directory it
        # was found in.
        plugins.enabled = [
          "noctalia/screen_recorder"
          "toph/arctis-battery"
        ];

        bar.main = {
          position = "top";
          background_opacity = 1.0;
          padding = 9;
          widget_spacing = 17;
          margin_h = 1;
          margin_v = 1;
          start = ["launcher" "workspaces"];
          center = ["clock" "media"];
          end = ["tray" "notifications" "toph/arctis-battery:battery" "volume" "control-center" "session"];
          monitor.dp3 = {
            match = "DP-3";
            position = "bottom";
            start = ["clock"];
            end = ["tray" "volume"];
          };
        };

        dock.enabled = false;
      };
    };

    systemd.user.services.noctalia-mirror-settings = {
      Unit.Description = "Copy noctalia's runtime settings into the working copy";
      Service = {
        Type = "oneshot";
        ExecStart = "${syncMirror}/bin/noctalia-mirror-settings";
      };
    };

    # Runs more often than dotfiles-sync so a refreshed mirror is usually
    # already in place when the hourly commit comes around.
    systemd.user.timers.noctalia-mirror-settings = {
      Unit.Description = "Periodic noctalia settings mirror refresh";
      Install.WantedBy = ["timers.target"];
      Timer = {
        OnBootSec = "5min";
        OnUnitActiveSec = "30min";
        Persistent = true;
      };
    };
  };
}
