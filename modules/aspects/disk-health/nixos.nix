# Drive health tooling, for hosts with disks that can answer for themselves.
#
# Separate from the baseline diagnostics every host carries, because a VPS on
# virtio devices exposes no SMART data and these tools would report nothing
# there. Inclusion is the switch: a host imports this when it has real disks.
{
  flake.modules.nixos.disk-health = {pkgs, ...}: {
    environment.systemPackages = with pkgs; [
      smartmontools
      nvme-cli
      hdparm # the SATA disks on fram, where nvme-cli is useless
    ];
  };
}
