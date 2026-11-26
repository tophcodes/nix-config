_: {
  flake.modules.homeManager.cheatsheet = {
    pkgs,
    config,
    lib,
    ...
  }: let
    # The command a package installs, which is what tldr indexes:
    # `ripgrep` has no page, `rg` does. mainProgram is the packager's own
    # answer to that question; pname is the fallback when none is declared.
    commandOf = p: p.meta.mainProgram or (p.pname or (lib.getName p));

    tools = lib.naturalSort (lib.unique (map commandOf config.home.packages));

    # Read at runtime rather than baked in: the script is itself one of the
    # packages the list is derived from, and embedding it would be a cycle.
    index = "${config.xdg.dataHome}/cheatsheet/tools";

    # Cascade per tool: a tldr page if one exists, otherwise the tool's own
    # help. Everything here is local: no query leaves the machine.
    render = ''
      tldr --color always {} 2>/dev/null \
        || { command -v {} >/dev/null 2>&1 && {} --help 2>&1 | head -80; } \
        || echo "No cheatsheet and no --help for {}"
    '';

    script = pkgs.writeShellApplication {
      name = "cheatsheet";
      runtimeInputs = [pkgs.fzf pkgs.tealdeer pkgs.coreutils];
      text = ''
        index="${index}"
        if [ ! -r "$index" ]; then
          echo "cheatsheet: no tool index at $index" >&2
          exit 1
        fi

        # Preview rather than pick-then-show: the sheet is visible while
        # scrolling, so browsing works without committing to a choice.
        selected="$(fzf --prompt 'tool> ' \
          --preview ${lib.escapeShellArg render} \
          --preview-window 'right:70%:wrap' \
          --header 'installed tools: enter to open, esc to leave' \
          < "$index")" || exit 0

        [ -n "$selected" ] || exit 0
        tldr --color always "$selected" 2>/dev/null \
          || "$selected" --help 2>&1 | head -80
      '';
    };
  in {
    home.packages = [script];

    xdg.dataFile."cheatsheet/tools".text = lib.concatStringsSep "\n" tools + "\n";

    programs.tealdeer = {
      enable = true;
      settings.updates.auto_update = true;
    };
  };
}
