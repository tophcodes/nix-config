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
    # claude-herdr-status, which documents the protocol and the labels. Its
    # `hooks` attribute holds the Claude Code hooks that run it.
    status = inputs.devkit.packages.${pkgs.stdenv.hostPlatform.system}.claude-herdr-status;
  in {
    # The workbench layout and its mods, linked from ~/code/devkit/herdr.
    imports = [inputs.devkit.modules.homeManager.herdr];

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
        --argjson hooks ${lib.escapeShellArg (builtins.toJSON status.hooks)} \
        '.hooks |= ((. // {})
           | with_entries(.value |= map(select(
               ((.hooks // []) | any((.command // "") | test("claude-herdr-status"))) | not
             )))
           | reduce ($hooks | to_entries[]) as $e (.;
               .[$e.key] = ((.[$e.key] // []) + $e.value)))' \
        "$settings_file" >"$settings_file.tmp"
      $DRY_RUN_CMD mv "$settings_file.tmp" "$settings_file"
    '';
  };
}
