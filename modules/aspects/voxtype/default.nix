{
  config,
  inputs,
  ...
}: let
  # Bound out here on purpose: the home-manager module below shadows `config`
  # with its own, where `flake.lib` does not exist.
  inherit (config.flake.lib) aspects;
in {
  flake.modules.homeManager.voxtype = {pkgs, ...}: let
    inherit (inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}) voxtype;
  in {
    imports = [
      # A directory, not the file: `voxtype configure` rewrites config.toml in
      # place, which would replace a file link with a regular copy on the
      # first save. Unset keys fall through to voxtype's built-in defaults, so
      # the tracked file only carries what actually differs.
      (aspects.mkSymlinks {".config/voxtype" = ./config;})
    ];

    home.packages = [voxtype];

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
        ExecStart = "${voxtype}/bin/voxtype daemon";
        Restart = "on-failure";
        RestartSec = 5;
      };

      Install.WantedBy = ["graphical-session.target"];
    };
  };
}
