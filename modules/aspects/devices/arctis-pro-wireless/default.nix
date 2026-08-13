# SteelSeries Arctis Pro Wireless — battery, sidetone and inactive-time over its
# base station, via headsetcontrol.
#
# The udev rules are the load-bearing half: the headset speaks over hidraw, and
# without a `uaccess` tag on its interface every query fails with "Could not
# open device" while enumeration still succeeds — so the tool reports the
# headset as present and its battery as unavailable.
#
# The rules file ships the whole Arctis family, not just this model. The aspect
# is still named for the device because inclusion is the switch: a host imports
# it when the base station actually gets plugged in there.
{
  flake.modules.nixos.arctis-pro-wireless = {pkgs, ...}: {
    environment.systemPackages = [pkgs.headsetcontrol];
    services.udev.packages = [pkgs.headsetcontrol];
  };
}
