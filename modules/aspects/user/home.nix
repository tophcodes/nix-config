{config, ...}: let
  # See nixos.nix — `config` is shadowed inside the module below.
  inherit (config.flake) defaultUser;
in {
  # The home-manager half of the same user. Separate module system, so the
  # option is declared a second time rather than shared; the default comes
  # from `flake.defaultUser` either way, which is what keeps them aligned.
  #
  # What a user *has* stays host-specific (home/by-host/<host>) — toph on
  # endurance needs far more than toph on vasa. This module only settles who
  # the user is.
  flake.modules.homeManager.user = {
    config,
    lib,
    pkgs,
    ...
  }: {
    options.fleet.user.name = lib.mkOption {
      type = lib.types.str;
      default = defaultUser;
      description = "Login name this home belongs to.";
    };

    # A standalone homeManagerConfiguration has no system user to infer these
    # from, and `agenix rekey -a` aborts on a missing home.username while it
    # collects host info.
    config.home = {
      username = config.fleet.user.name;
      homeDirectory =
        if pkgs.stdenv.hostPlatform.isDarwin
        then "/Users/${config.fleet.user.name}"
        else "/home/${config.fleet.user.name}";
    };
  };
}
