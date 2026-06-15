{
  pkgs,
  config,
  ...
}: {
  home.packages = with pkgs; [
    # Shell software
    fzf # Fuzzy finding
    fd # Fast find alternative
    bat # cat alternative
    zellij # terminal workspace
    silver-searcher # ag search tool
    gum
    glow # Render markdown in the terminal
    wl-clipboard # wl-copy / wl-paste for Wayland

    # Nix tooling (used by Claude Code hooks + nix fmt)
    alejandra
    statix
    deadnix

    openssl # TLS/crypto CLI

    httpie # HTTP client / CURL alternative

    genact # Jibberish output ("I'm waiting for a compile.")
    cbonsai # Create bonsai trees
  ];

  programs = {
    yazi = {
      enable = true;
      shellWrapperName = "yy";
      keymap.mgr.prepend_keymap = [
        {
          on = ["c" "g"];
          run = [
            ''shell 'cat "$@" | wl-copy' ''
            "yank"
          ];
          desc = "Copy hovered/selected file contents to Wayland clipboard";
        }
        {
          on = "!";
          for = "unix";
          run = ''shell "$SHELL" --block'';
          desc = "Open $SHELL here";
        }
        {
          on = "<C-n>";
          run = "shell -- ${pkgs.ripdrag}/bin/ripdrag %s -x 2>/dev/null &";
          desc = "Drag and drop selected files";
        }
      ];
    };

    atuin = {
      # Better (and synchronized) shell history
      enable = true;
      enableNushellIntegration = config.programs.nushell.enable;
      enableFishIntegration = config.programs.fish.enable;
    };

    zoxide = {
      # Quick-jump to folders (z / zi); cd stays as builtin cd
      enable = true;
      enableNushellIntegration = config.programs.nushell.enable;
      enableFishIntegration = config.programs.fish.enable;
    };

    carapace = {
      # Shell completions
      enable = true;
      enableNushellIntegration = config.programs.nushell.enable;
      enableFishIntegration = config.programs.fish.enable;
    };

    dircolors = {
      # Override coreutils' built-in `ow`/`tw` defaults (blue/black on bright
      # green), which collide with everforest's green palette on symlink
      # targets pointing to world-writable dirs.
      enable = true;
      enableFishIntegration = config.programs.fish.enable;
      enableNushellIntegration = config.programs.nushell.enable;
      enableBashIntegration = true;
      settings = {
        # Bold white on everforest bg_green (#425047).
        OTHER_WRITABLE = "01;37;48;2;66;80;71";
        STICKY_OTHER_WRITABLE = "01;37;48;2;66;80;71";
      };
    };
  };
}
