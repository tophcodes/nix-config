# herdr-core (`hc`) on a machine that other cores add over ssh: the package for
# each agent user, and a user unit that starts the core at boot, so kept
# terminals get their shells back without waiting for the first connection.
# The core runs as its own transient unit and needs the user to linger.
{inputs, ...}: {
  flake.modules.nixos.herdr-core = {
    config,
    lib,
    pkgs,
    ...
  }: let
    # Only in nixpkgs master so far.
    herdr-core = inputs.master.legacyPackages.${pkgs.stdenv.hostPlatform.system}.herdr-core;
    inherit (config.herdr-core) users;
  in {
    options.herdr-core.users = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = ["toph"];
      description = "Users that get hc and run their own core from boot.";
    };

    config = {
      users.users = lib.genAttrs users (_: {
        packages = [herdr-core];
        linger = true;
      });

      systemd.user.services.herdr-core = {
        description = "Start herdr-core";
        wantedBy = ["default.target"];
        # NixOS installs user units for every user; only the listed users run
        # hc. The `|` prefix ORs the conditions.
        unitConfig.ConditionUser = map (u: "|${u}") users;
        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = true;
          ExecStart = "${herdr-core}/bin/hc server start";
        };
      };
    };
  };
}
