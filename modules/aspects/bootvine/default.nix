{inputs, ...}: {
  # bootvine draws the boot and the shutdown on the console as a live tree of
  # pending systemd jobs, followed by a timeline of the slowest units. It starts
  # in the systemd initrd, which NixOS 26.05 uses by default, and hands the
  # console over once the display manager takes its terminal.
  flake.modules.nixos.bootvine = {
    imports = [inputs.bootvine.nixosModules.default];
    services.bootvine.enable = true;
  };
}
