# The herdr desktop app and herdr-core (`hc`), the terminal runtime it drives.
# Both come from nixpkgs master until a channel carries them.
{inputs, ...}: {
  flake.modules.homeManager.herdr-app = {
    pkgs,
    lib,
    ...
  }: let
    # Claude Code reports its state to herdr-core and labels its terminal with
    # the repositories the session works in; the script is devkit's
    # claude-herdr-status, which documents the protocol and the labels.
    status = inputs.devkit.packages.${pkgs.stdenv.hostPlatform.system}.claude-herdr-status;

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
