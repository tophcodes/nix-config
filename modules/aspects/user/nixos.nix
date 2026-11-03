{config, ...}: let
  # Bound out here on purpose: the NixOS module below shadows `config` with
  # its own, where `flake.defaultUser` does not exist.
  inherit (config.flake) defaultUser;
in {
  # The host's primary human user. Servers do not import this — they are
  # reached as root over SSH and have no interactive account at all.
  #
  # Modules that grant this user a group, a path or a service reference
  # `config.fleet.user.name` instead of spelling the login name out, so a host
  # that names its user differently stays consistent without edits elsewhere.
  flake.modules.nixos.user = {
    config,
    lib,
    pkgs,
    ...
  }: let
    cfg = config.fleet.user;
  in {
    options.fleet.user = lib.mkOption {
      default = null;
      description = ''
        The host's primary human user, or null for a host that has none —
        a server reached as root over SSH.

        Null rather than absent so that a module can ask whether this host
        has a user at all. Importing this aspect on a server is therefore
        harmless and buys exactly that: `config.fleet.user != null` becomes
        answerable instead of throwing "option does not exist".
      '';
      type = lib.types.nullOr (lib.types.submodule {
        options = {
          name = lib.mkOption {
            type = lib.types.str;
            default = defaultUser;
            description = "Login name of the host's primary human user.";
          };

          uid = lib.mkOption {
            type = lib.types.int;
            default = 1000;
            description = "Numeric uid, reused as the gid of the user's own group.";
          };

          passwordFile = lib.mkOption {
            type = lib.types.nullOr lib.types.path;
            default = null;
            description = ''
              Path to a file holding the hashed password. Left null the
              password stays imperative, which is the right default for a
              workstation: hashedPasswordFile only takes effect with
              mutableUsers = false, and that disables passwd — including the
              re-keying pam_gnome_keyring does when the login password changes.
            '';
          };

          authorizedKeys = lib.mkOption {
            type = lib.types.listOf lib.types.str;
            default = [
              "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBEqcR3f71g7yuxQtUewrqdoEh8jDHtkB1973GF0EQ6q christopher@all"
              "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPwi5yYAHVkot7uqeEq+j37Eb7E1uLtiMOroyj9xw8/Q u0_a260@localhost"
            ];
            description = "SSH public keys accepted for this user.";
          };
        };
      });
    };

    config = lib.mkIf (cfg != null) {
      programs.fish.enable = true;

      users.users.${cfg.name} = {
        isNormalUser = true;
        inherit (cfg) uid;
        initialPassword = "wheel";
        hashedPasswordFile = cfg.passwordFile;
        shell = pkgs.fish;

        extraGroups = [
          "wheel"
          "docker"
          "dialout"
          "uinput"
          "pico"
        ];

        openssh.authorizedKeys.keys = cfg.authorizedKeys;
      };

      users.groups.${cfg.name} = {
        members = [cfg.name];
        gid = cfg.uid;
      };

      # Kept declared so the secret stays in the rekey set; it is only wired
      # up when a host opts into passwordFile above.
      age.secrets.tophPassword.rekeyFile = ./toph-password.age;
    };
  };
}
