{
  config,
  inputs,
  ...
}: let
  # Bound out here on purpose: the home-manager module below shadows `config`
  # with its own, where `flake.lib` does not exist.
  inherit (config.flake.lib) aspects;

  # Both halves of the transcript inbox. Phone dictations are meant to land
  # here too, so the layout is by capture kind, not by tool.
  transcripts = "pod/inbox/transcripts";
in {
  flake.modules.homeManager.voxtype = {pkgs, ...}: let
    inherit (inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}) voxtype;

    inbox = "$HOME/${transcripts}";

    # Serves this aspect only — it drives the bar button and nothing else,
    # which is why it lives here rather than in packages/.
    capture = pkgs.writeShellApplication {
      name = "voxtype-capture";
      runtimeInputs = [voxtype pkgs.jq pkgs.libnotify pkgs.coreutils];
      text = ''
        recorder="${inbox}/recorder"

        # `meeting status` exits 0 either way and only says so in prose.
        meeting_active() {
          ! voxtype meeting status 2>/dev/null | grep -q "No meeting currently in progress"
        }

        rec_state() {
          voxtype status --format json 2>/dev/null | jq -r '.alt // "idle"'
        }

        # notify-send -A implies --wait and prints the chosen action to stdout.
        # An expired or dismissed notification yields an empty string, which
        # every caller below treats as "do nothing".
        ask() {
          local summary="$1"
          shift
          notify-send --app-name=voxtype "$summary" "$@" 2>/dev/null || true
        }

        case "''${1:-toggle}" in
          status)
            if meeting_active; then
              echo "meeting"
            else
              case "$(rec_state)" in
                recording) echo "rec" ;;
                transcribing) echo "…" ;;
                *) echo "idle" ;;
              esac
            fi
            ;;

          meeting)
            if meeting_active; then
              notify-send --app-name=voxtype "Meeting läuft bereits" \
                "Linksklick beendet es."
            else
              voxtype meeting start
            fi
            ;;

          toggle)
            if meeting_active; then
              case "$(ask "Meeting beenden?" \
                -A stop="Beenden" -A keep="Weiterlaufen")" in
                stop) voxtype meeting stop ;;
              esac
            elif [ "$(rec_state)" = "recording" ]; then
              case "$(ask "Aufnahme beenden?" \
                -A stop="Beenden und transkribieren" \
                -A cancel="Verwerfen" \
                -A keep="Weiter aufnehmen")" in
                stop) voxtype record stop ;;
                cancel) voxtype record cancel ;;
              esac
            else
              mkdir -p "$recorder"
              voxtype record start --file="$recorder/$(date +%Y-%m-%dT%H-%M-%S).txt"
            fi
            ;;

          *)
            echo "usage: voxtype-capture [toggle|meeting|status]" >&2
            exit 64
            ;;
        esac
      '';
    };
  in {
    imports = [
      # A directory, not the file: `voxtype configure` rewrites config.toml in
      # place, which would replace a file link with a regular copy on the
      # first save. voxtype validates the file as a whole, so it carries
      # voxtype's complete defaults rather than only our overrides.
      (aspects.mkSymlinks {".config/voxtype" = ./config;})
    ];

    home.packages = [voxtype capture];

    # Push-to-talk is a compositor bind rather than voxtype's built-in evdev
    # hotkey — the latter needs the user in the `input` group. The bind lives
    # with the host's other keybinds.
    systemd.user.services.voxtype = {
      Unit = {
        Description = "voxtype push-to-talk voice-to-text daemon";
        Documentation = "https://voxtype.io";
        # Needs a compositor to type into and PipeWire to record from.
        PartOf = ["graphical-session.target"];
        After = ["graphical-session.target" "pipewire.service" "pipewire-pulse.service"];
      };

      Service = {
        Type = "simple";
        # meeting.storage_path has to exist before the first meeting starts,
        # and it lives in the vault rather than under the daemon's state dir.
        # `%h` rather than $HOME: systemd expands the specifier itself, so
        # this does not depend on HOME being in the unit's environment.
        ExecStartPre = "${pkgs.coreutils}/bin/mkdir -p %h/${transcripts}/meetings %h/${transcripts}/recorder";
        ExecStart = "${voxtype}/bin/voxtype daemon";
        Restart = "on-failure";
        RestartSec = 5;
      };

      Install.WantedBy = ["graphical-session.target"];
    };
  };
}
