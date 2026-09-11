{inputs, ...}: {
  flake.modules.homeManager.diversion = {pkgs, ...}: let
    dv = inputs.self.packages.${pkgs.stdenv.hostPlatform.system}.diversion;
  in {
    home.packages = [dv];

    # The Unreal source-control plugin looks for the binary at this exact path
    # rather than on PATH, and starts the agent itself when it finds no live
    # one. Keeping the link declarative means the editor keeps working when the
    # unit below is stopped.
    home.file.".diversion/bin/dv".source = "${dv}/bin/dv";

    # Diversion's clients talk to a local sync agent over HTTP. Without a unit
    # the agent is whatever child process happened to start it: the CLI leaves
    # one behind in the shell's scope, the Unreal plugin spawns one into the
    # editor's cgroup, and stopping either takes source control down with it.
    #
    # The agent picks its own port on every start and writes it to
    # ~/.diversion/.port, which every client re-reads per request, so nothing
    # here has to pin one.
    systemd.user.services.diversion-agent = {
      Unit = {
        Description = "Diversion sync agent";
        After = ["network-online.target"];
        Wants = ["network-online.target"];
      };
      Service = {
        Type = "simple";
        ExecStart = "${dv}/bin/dv --agent";
        Restart = "on-failure";
        RestartSec = "5s";
      };
      Install.WantedBy = ["default.target"];
    };
  };
}
