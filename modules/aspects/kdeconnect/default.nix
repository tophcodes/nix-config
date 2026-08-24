{config, ...}: let
  # Bound out here on purpose: the home-manager module below shadows `config`
  # with its own, where `flake.lib` does not exist.
  inherit (config.flake.lib) aspects;
in {
  # The whole per-device directory is linked, not just the sendnotifications
  # payload: the plugin enable flags live in `config` beside it, and both are
  # needed to reproduce the setup. Linking either file on its own would not
  # survive QSettings' atomic save, which replaces a file symlink with a
  # regular file.
  #
  # The path segment is the device id, minted when the phone was paired.
  # Nothing derives it, and re-pairing mints a new one — the link would then
  # point at a directory kdeconnect no longer reads.
  flake.modules.homeManager.kdeconnect = {
    imports = [
      (aspects.mkSymlinks {
        ".config/kdeconnect/49e4bbd37fc7473db8b34351473130f5" = ./config;
      })
    ];
  };
}
