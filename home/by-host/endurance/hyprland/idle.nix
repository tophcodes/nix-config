{
  pkgs,
  lib,
  ...
}: let
  hyprctl = lib.getExe' pkgs.hyprland "hyprctl";
  loginctl = lib.getExe' pkgs.systemd "loginctl";

  # Animated, *locked* screensaver. swaylock-plugin is a real ext-session-lock
  # locker (PAM auth) that can render an arbitrary wlr-layer-shell client as its
  # background. windowtolayer wraps an ordinary terminal app into such a layer
  # surface, so cmatrix — sparse moving green on black, low average luminance +
  # motion, i.e. OLED-cheap — runs *inside* the lock surface. A normal lock
  # blanks all other windows (ext-session-lock), so the animation has to BE the
  # lock background; this is the only way to get "animated AND locked" at once.
  # One instance per output (--command-each). Requires the `swaylock` PAM service
  # on the host (hosts/endurance/default.nix) or unlock can't authenticate.
  locker = pkgs.writeShellScript "oled-lock" ''
    ${pkgs.procps}/bin/pgrep -x swaylock-plugin >/dev/null && exit 0
    exec ${pkgs.swaylock-plugin}/bin/swaylock-plugin \
      --command-each '${lib.getExe pkgs.windowtolayer} -- ${lib.getExe pkgs.kitty} -o background=#000000 -o background_opacity=1.0 -o font_size=16 -e ${lib.getExe pkgs.cmatrix} -abu 5'
  '';
in {
  home.packages = with pkgs; [swaylock-plugin windowtolayer cmatrix];

  services.hypridle = {
    enable = true;
    settings = {
      general = {
        lock_cmd = "${locker}";
        before_sleep_cmd = "${loginctl} lock-session";
        after_sleep_cmd = "${hyprctl} dispatch dpms on";
        # Honor idle inhibitors: a fullscreen video (Firefox/Chrome/mpv) holds a
        # Wayland idle-inhibitor, so the compositor never reports idle and none
        # of these timers fire while it plays. That is the "except YouTube" case.
        ignore_dbus_inhibit = false;
        ignore_systemd_inhibit = false;
      };
      listener = [
        # 30 min: lock + animated screensaver (cmatrix lives inside the lock).
        {
          timeout = 1800;
          on-timeout = "${loginctl} lock-session";
        }
        # 45 min: power the panel off entirely (session already locked).
        {
          timeout = 2700;
          on-timeout = "${hyprctl} dispatch dpms off";
          on-resume = "${hyprctl} dispatch dpms on";
        }
      ];
    };
  };
}
