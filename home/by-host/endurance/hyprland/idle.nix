{
  pkgs,
  lib,
  ...
}: let
  hyprctl = lib.getExe' pkgs.hyprland "hyprctl";
  loginctl = lib.getExe' pkgs.systemd "loginctl";

  # hyprlock is the native Hyprland ext-session-lock client (PAM auth against the
  # `hyprlock` service, declared on the host). It has no animation redraw loop, so
  # it can't repeat the swaylock-plugin 1.8.6 SEGV in output_redraw_timeout that
  # killed the lock surface mid-session and wedged the compositor into the
  # "your locker crashed, switch TTY" state. Background is solid OLED black —
  # cheap on the panel, no live cmatrix. Single-instance guard so a second
  # lock-session signal doesn't spawn a duplicate locker.
  locker = pkgs.writeShellScript "oled-lock" ''
    ${pkgs.procps}/bin/pgrep -x hyprlock >/dev/null && exit 0
    exec ${lib.getExe pkgs.hyprlock}
  '';
in {
  # Colors (background + input-field) come from Stylix's hyprlock target (base16
  # palette, near-black base00 — OLED-cheap). Only the non-themed behaviour knobs
  # live here.
  programs.hyprlock = {
    enable = true;
    settings.general = {
      disable_loading_bar = true;
      hide_cursor = true;
    };
  };

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
        # 30 min: lock (hyprlock, solid black).
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
