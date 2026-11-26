{lib, ...}: {
  # The one place the login name is written down. Both the NixOS side
  # (nixos.nix) and the home-manager side (home.nix) take their default from
  # here, so the two module systems cannot drift apart.
  #
  # This travels inward only: read in the outer module scope to seed a
  # default, never read back out of a host's evaluated config.
  options.flake.defaultUser = lib.mkOption {
    type = lib.types.str;
    default = "toph";
    description = "Login name assumed for a host's primary human user unless it overrides fleet.user.name.";
  };
}
