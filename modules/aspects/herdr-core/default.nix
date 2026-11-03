# herdr-core (`hc`) on a machine that other cores add over ssh: the package for
# the agent user, and a user unit that starts the core at boot, so kept
# terminals get their shells back without waiting for the first connection.
# The core runs as its own transient unit and needs the user to linger.
{inputs, ...}: {
  flake.modules.nixos.herdr-core = {pkgs, ...}: let
    # Only in nixpkgs master so far.
    herdr-core = inputs.master.legacyPackages.${pkgs.stdenv.hostPlatform.system}.herdr-core;
  in {
    users.users.toph = {
      packages = [herdr-core];
      linger = true;
    };

    systemd.user.services.herdr-core = {
      description = "Start herdr-core";
      wantedBy = ["default.target"];
      # NixOS installs user units for every user; only the agent user runs hc.
      unitConfig.ConditionUser = "toph";
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        ExecStart = "${herdr-core}/bin/hc server start";
      };
    };
  };
}
