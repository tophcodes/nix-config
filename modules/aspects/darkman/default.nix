# darkman holds the session's light/dark preference and serves it as the
# xdg-desktop-portal `org.freedesktop.appearance color-scheme` setting. Apps
# that follow the portal (kitty, Zed, VS Code, GTK4, Qt, Firefox) switch live
# on its signal. The portal side lives in the graphical NixOS aspect, which
# names darkman as the Settings backend.
#
# noctalia's theme toggle drives it: a hook calls `darkman set` on every mode
# change. darkman itself never switches on its own, because it has no location.
_: {
  flake.modules.homeManager.darkman = _: {
    services.darkman = {
      enable = true;
      settings = {
        usegeoclue = false;
        portal = true;
        dbusserver = true;
      };
    };
  };
}
