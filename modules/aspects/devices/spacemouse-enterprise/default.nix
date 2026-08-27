# 3Dconnexion SpaceMouse Enterprise — write access to its USB device node, so
# the LCD panel can be driven, and removal of its evdev node from libinput.
#
# The panel is addressed over libusb, which writes to /dev/bus/usb/BBB/DDD. The
# hidraw node carrying the motion axes is a separate device and grants nothing
# here.
#
# The rules ship as their own file instead of through `services.udev.extraRules`
# because of ordering. `TAG+="uaccess"` is only a marker; the builtin that turns
# it into an ACL for the logged-in user runs from systemd's 73-seat-late.rules,
# and udev merges every rules directory into one filename-ordered sequence.
# `extraRules` always lands in 99-local.rules, so the tag would be set long
# after the builtin had already run and no ACL would ever appear. Any number
# below 73 fixes that; every uaccess rule that works on this machine is one.
#
# `uaccess` also keeps the grant scoped to whoever is logged in at the seat,
# which matters for a device whose firmware is writable through that node.
#
# The device's HID interface produces exactly one evdev node, and that node
# carries the six axes, the function buttons and a KEY bitmap covering the
# whole 0-255 keycode range at once. libinput reads the key capability off the
# kernel bits and forwards every function button to the focused window as a
# real keystroke, which applications receive as ordinary typing and cannot
# refuse. `LIBINPUT_IGNORE_DEVICE` takes the node away from libinput alone;
# spacenavd scans /dev/input itself and never goes through it, so the axes and
# buttons keep arriving over the spacenav socket.
#
# Both rules match on `ATTRS` rather than `ID_VENDOR_ID`, because at 60-3 the
# usb_id builtin has not run yet — it runs from 60-persistent-input.rules,
# which sorts later.
{
  flake.modules.nixos.spacemouse-enterprise = {pkgs, ...}: {
    services.udev.packages = [
      (pkgs.writeTextFile {
        name = "spacemouse-enterprise-udev-rules";
        destination = "/etc/udev/rules.d/60-3dconnexion.rules";
        text = ''
          SUBSYSTEM=="usb", ATTRS{idVendor}=="256f", ATTRS{idProduct}=="c633", TAG+="uaccess"
          SUBSYSTEM=="input", KERNEL=="event*", ATTRS{idVendor}=="256f", ATTRS{idProduct}=="c633", ENV{LIBINPUT_IGNORE_DEVICE}="1"
        '';
      })
    ];
  };
}
