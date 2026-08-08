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
  transcripts = "pod/system/inbox/transcripts";
in {
  flake.modules.homeManager.voxtype = {pkgs, ...}: let
    inherit (pkgs.stdenv.hostPlatform) system;
    # Not llm-agents' voxtype: that is the CPU-only build, which pins the CPU
    # for the length of every transcription. This one runs whisper.cpp on the
    # GPU through Vulkan.
    inherit (inputs.self.packages.${system}) voxtype-vulkan voxtype-osd-gtk4;
    voxtype = voxtype-vulkan;

    # llm-agents ships the daemon and the `voxtype-osd` launcher but not the
    # frontend the launcher execs into, so this one is built here too.
    osd = voxtype-osd-gtk4;

    inbox = "$HOME/${transcripts}";

    # Serves this aspect only — it wraps voxtype's verbs with the inbox paths
    # and nothing else, which is why it lives here rather than in packages/.
    capture = pkgs.writeShellApplication {
      name = "voxtype-capture";
      runtimeInputs = [voxtype pkgs.jq pkgs.libnotify pkgs.coreutils];
      text = ''
        recorder="${inbox}/recorder"
        meetings="${inbox}/meetings"
        # Where the running dictation is being written. `stop` is a separate
        # invocation, so the path has to survive between the two.
        last="''${XDG_RUNTIME_DIR:-/tmp}/voxtype-capture.last"

        # `meeting status` exits 0 either way and only says so in prose.
        meeting_active() {
          ! voxtype meeting status 2>/dev/null | grep -q "No meeting currently in progress"
        }

        rec_state() {
          voxtype status --format json 2>/dev/null | jq -r '.alt // "idle"'
        }

        case "''${1:-status}" in
          dictate)
            mkdir -p "$recorder"
            # .md, not .txt: Obsidian only indexes markdown, and this lands
            # in the vault.
            target="$recorder/$(date +%Y-%m-%dT%H-%M-%S).md"
            printf '%s' "$target" > "$last"
            voxtype record start --file="$target"
            notify-send --app-name=voxtype "Dictation started" "→ ''${target/#$HOME/\~}"
            ;;

          meeting)
            if meeting_active; then
              notify-send --app-name=voxtype "A meeting is already running"
            else
              voxtype meeting start
              notify-send --app-name=voxtype "Meeting started" "Microphone and system audio"
            fi
            ;;

          # One verb for both, so the launcher entries do not have to know
          # which kind of capture is running.
          stop)
            if meeting_active; then
              voxtype meeting stop
              mkdir -p "$meetings"
              target="$meetings/$(date +%Y-%m-%dT%H-%M-%S).md"
              # Meetings are stored as transcript.json; markdown with
              # timestamps and speaker labels is what is actually readable.
              if voxtype meeting export latest --format markdown \
                   --timestamps --speakers --output "$target" 2>/dev/null; then
                notify-send --app-name=voxtype "Meeting saved" "→ ''${target/#$HOME/\~}"
              else
                notify-send --app-name=voxtype "Meeting stopped" "Export failed, see: voxtype meeting list"
              fi
            elif [ "$(rec_state)" = "recording" ]; then
              voxtype record stop
              target="$(cat "$last" 2>/dev/null || true)"
              if [ -n "$target" ]; then
                # Transcription runs after `stop` returns, so the file appears
                # a moment later. Bounded wait rather than a fixed sleep.
                for _ in $(seq 1 120); do
                  [ -s "$target" ] && break
                  sleep 0.5
                done
                if [ -s "$target" ]; then
                  # A dictation is one utterance, so it carries no segment
                  # timestamps — the capture time is the only one there is,
                  # and it belongs in the note rather than only the filename.
                  stamp="$(basename "$target" .md | sed 's/T/ /; s/-\([0-9][0-9]\)-\([0-9][0-9]\)$/:\1:\2/')"
                  {
                    printf -- '---\ncreated: %s\nsource: voxtype dictation\n---\n\n' "$stamp"
                    cat "$target"
                    printf '\n'
                  } > "$target.tmp" && mv "$target.tmp" "$target"
                fi
                notify-send --app-name=voxtype "Dictation saved" "→ ''${target/#$HOME/\~}"
              else
                notify-send --app-name=voxtype "Dictation stopped"
              fi
            else
              notify-send --app-name=voxtype "Nothing to stop"
            fi
            ;;

          cancel)
            voxtype record cancel
            ;;

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

          *)
            echo "usage: voxtype-capture [dictate|meeting|stop|cancel|status]" >&2
            exit 64
            ;;
        esac
      '';
    };

    # Any app opening a recording stream shows up as a PulseAudio
    # source-output, so this catches Meet, Zoom, Teams and a Discord call
    # alike without knowing anything about them.
    meetwatch = pkgs.writeShellApplication {
      name = "voxtype-meetwatch";
      runtimeInputs = [voxtype pkgs.pulseaudio pkgs.libnotify pkgs.gnused pkgs.gnugrep];
      text = ''
        # voxtype itself records too — matching it would make a dictation ask
        # whether to transcribe the dictation.
        watched='firefox|chrom|zoom|teams|discord|slack|element|webex'

        recording_apps() {
          pactl list source-outputs 2>/dev/null \
            | sed -n 's/^[[:space:]]*application\.name = "\(.*\)"$/\1/p' \
            | grep -Ei "$watched" || true
        }

        meeting_active() {
          ! voxtype meeting status 2>/dev/null | grep -q "No meeting currently in progress"
        }

        offered=""

        consider() {
          local app
          app="$(recording_apps | head -1)"

          # Stream gone: re-arm, so the next call offers again.
          if [ -z "$app" ]; then
            offered=""
            return 0
          fi

          if [ "$app" = "$offered" ] || meeting_active; then
            return 0
          fi
          offered="$app"

          local answer
          answer="$(notify-send --app-name=voxtype \
            -A yes="Transcribe" -A no="No thanks" \
            "Meeting detected" "$app is recording." 2>/dev/null || true)"
          if [ "$answer" = "yes" ]; then
            voxtype meeting start
          fi
        }

        consider
        # Process substitution rather than a pipe: a piped `while` runs in a
        # subshell and would lose `offered` on every iteration.
        while read -r line; do
          case "$line" in
            *source-output*)
              # PulseAudio announces the stream before the client metadata is
              # attached; without this the name is still empty.
              sleep 1
              consider
              ;;
          esac
        done < <(pactl subscribe 2>/dev/null)
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

    home.packages = [voxtype osd capture meetwatch];

    # Reachable from the launcher, which is where these are actually used —
    # the keybinds are the shortcut, not the only door.
    xdg.desktopEntries = {
      voxtype-dictate = {
        name = "Start dictation";
        comment = "Record a dictation into the transcript inbox";
        exec = "${capture}/bin/voxtype-capture dictate";
        icon = "audio-input-microphone";
        terminal = false;
        categories = ["Utility" "AudioVideo"];
      };
      voxtype-meeting = {
        name = "Record meeting";
        comment = "Transcribe continuously, microphone and system audio";
        exec = "${capture}/bin/voxtype-capture meeting";
        icon = "audio-input-microphone";
        terminal = false;
        categories = ["Utility" "AudioVideo"];
      };
      voxtype-stop = {
        name = "Stop capture";
        comment = "End the running dictation or meeting";
        exec = "${capture}/bin/voxtype-capture stop";
        icon = "media-playback-stop";
        terminal = false;
        categories = ["Utility" "AudioVideo"];
      };
    };

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
        # Environment= replaces PATH rather than extending it, so both halves
        # have to be named: the daemon spawns `voxtype-osd` from its own
        # package, and that launcher then resolves the frontend off PATH.
        # Typing and clipboard backends are wrapped into the voxtype binary
        # itself and do not belong here.
        Environment = ["PATH=${voxtype}/bin:${osd}/bin:/run/current-system/sw/bin"];
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

    systemd.user.services.voxtype-meetwatch = {
      Unit = {
        Description = "Offer to transcribe when a meeting app opens the microphone";
        PartOf = ["graphical-session.target"];
        # Needs the notification daemon up to be able to ask anything.
        After = ["graphical-session.target" "pipewire-pulse.service"];
      };

      Service = {
        Type = "simple";
        ExecStart = "${meetwatch}/bin/voxtype-meetwatch";
        Restart = "on-failure";
        RestartSec = 10;
      };

      Install.WantedBy = ["graphical-session.target"];
    };
  };
}
