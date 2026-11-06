# The herdr desktop app and herdr-core (`hc`), the terminal runtime it drives.
# Both come from nixpkgs master until a channel carries them.
{inputs, ...}: {
  flake.modules.homeManager.herdr-app = {
    pkgs,
    lib,
    ...
  }: let
    # Claude Code reports its state to herdr-core as OSC 7501, the Program
    # Status Protocol: `ESC ] 7501 ; state=<state>:app=claude-code[:kind=<kind>] ESC \`.
    # Core stores it per terminal, so herdr-app and every other client of the
    # core API list the session as an agent.
    #
    # A hook has no controlling terminal, so the report goes to the
    # pseudo-terminal Claude Code reads from: the first ancestor whose stdin is
    # a /dev/pts device. Outside a herdr-core terminal (no HC_TERMINAL_ID) it
    # writes nothing.
    #
    # The script also labels its terminal `herdr.folder=<cwd>` with the folder
    # Claude Code works in. herdr reads a terminal's folder from the process,
    # which stays where the session started, and ignores OSC 7. The explorer
    # mods and the pane header read the label instead.
    status = pkgs.writeShellApplication {
      name = "claude-herdr-status";
      runtimeInputs = [pkgs.coreutils pkgs.procps pkgs.jq];
      text = ''
        state="$1"
        kind="''${2:-}"
        input="$(cat || true)"
        [ -n "''${HC_TERMINAL_ID:-}" ] || exit 0

        folder="$(jq -r '.cwd // empty' <<<"$input" 2>/dev/null || true)"
        if [ -n "$folder" ] && command -v hc >/dev/null; then
          hc label "$HC_TERMINAL_ID" "herdr.folder=$folder" >/dev/null 2>&1 || true
        fi

        pid="$PPID"
        tty=""
        while [ "$pid" -gt 1 ]; do
          target="$(readlink "/proc/$pid/fd/0" 2>/dev/null || true)"
          case "$target" in
            /dev/pts/*) tty="$target"; break ;;
          esac
          pid="$(ps -o ppid= -p "$pid" | tr -d ' ')"
          [ -n "$pid" ] || exit 0
        done
        [ -n "$tty" ] || exit 0

        report="state=$state:app=claude-code"
        [ -z "$kind" ] || report="$report:kind=$kind"
        printf '\033]7501;%s\033\134' "$report" >"$tty" 2>/dev/null || true
      '';
    };

    # Hook event, optional matcher, and the arguments for the status script.
    # Stop reports `done`; herdr-app turns it into `idle` once the session is
    # looked at. PostToolUse clears `blocked` after a permission was granted.
    hooks = [
      {
        event = "SessionStart";
        args = "idle";
      }
      {
        event = "UserPromptSubmit";
        args = "working";
      }
      {
        event = "PostToolUse";
        args = "working";
      }
      {
        event = "Notification";
        matcher = "permission_prompt";
        args = "blocked permission";
      }
      {
        event = "Notification";
        matcher = "elicitation_dialog";
        args = "blocked question";
      }
      {
        event = "Stop";
        args = "done";
      }
      {
        event = "SessionEnd";
        args = "clear";
      }
    ];
  in {
    home.packages =
      (with inputs.master.legacyPackages.${pkgs.stdenv.hostPlatform.system}; [
        herdr-desktop
        herdr-core
      ])
      ++ [inputs.self.packages.${pkgs.stdenv.hostPlatform.system}.pt];

    # ~/.claude/settings.json is live, hand-maintained state, so the hooks are
    # merged in like the claude aspect's skill-sync hook: earlier entries are
    # matched by script name, because the store path moves on every rebuild.
    home.activation.claudeHerdrStatusHooks = lib.hm.dag.entryAfter ["writeBoundary"] ''
      settings_file="$HOME/.claude/settings.json"
      if [[ ! -f "$settings_file" ]]; then
        $DRY_RUN_CMD mkdir -p "$(dirname "$settings_file")"
        $DRY_RUN_CMD printf '{}' >"$settings_file"
      fi
      $DRY_RUN_CMD ${pkgs.jq}/bin/jq \
        --arg bin "${status}/bin/claude-herdr-status" \
        --argjson hooks ${lib.escapeShellArg (builtins.toJSON hooks)} \
        '.hooks |= ((. // {})
           | with_entries(.value |= map(select(
               ((.hooks // []) | any((.command // "") | test("claude-herdr-status"))) | not
             )))
           | reduce $hooks[] as $h (.;
               .[$h.event] = ((.[$h.event] // [])
                 + [({hooks: [{type: "command", command: "\($bin) \($h.args)"}]}
                     + if $h.matcher then {matcher: $h.matcher} else {} end)])))' \
        "$settings_file" >"$settings_file.tmp"
      $DRY_RUN_CMD mv "$settings_file.tmp" "$settings_file"
    '';
  };
}
