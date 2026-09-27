{
  pkgs,
  lib,
  ...
}: let
  hyprctl = lib.getExe' pkgs.hyprland "hyprctl";
  loginctl = lib.getExe' pkgs.systemd "loginctl";

  # `hyprctl dispatch dpms on` without a monitor argument only wakes the outputs
  # the compositor still holds when the dispatch lands. While both panels sit
  # DPMS-off the LG TV drops its HPD line; aquamarine rescans the connectors and
  # reshuffles CRTCs, DP-3 loses its CRTC in that window and stays disabled with
  # its workspaces on a dark panel. Re-assert DPMS per monitor over a few
  # seconds so an output that comes back late is covered as well.
  wakeDisplays = pkgs.writeShellScript "wake-displays" ''
    for _ in 1 2 3; do
      for m in $(${hyprctl} -j monitors all | ${lib.getExe pkgs.jq} -r '.[].name'); do
        ${hyprctl} dispatch dpms on "$m"
      done
      ${pkgs.coreutils}/bin/sleep 2
    done
  '';

  # hyprlock is the native Hyprland ext-session-lock client (PAM auth against the
  # `hyprlock` service, declared on the host). It has no animation redraw loop, so
  # it can't repeat the swaylock-plugin 1.8.6 SEGV in output_redraw_timeout that
  # killed the lock surface mid-session and wedged the compositor into the
  # "your locker crashed, switch TTY" state. Background is solid OLED black —
  # cheap on the panel, no live cmatrix. Single-instance guard so a second
  # lock-session signal doesn't spawn a duplicate locker.
  #
  # XKB_DEFAULT_*: hyprlock does NOT read Hyprland's `input:kb_layout`/`kb_variant`
  # — it builds its xkb keymap from these env vars, falling back to plain `us`
  # (no `intl` variant) if unset. The compositor here runs us+intl with dead keys
  # ('"`~^), so without this the same keystrokes produce different bytes inside the
  # locker → pam_unix rejects the password (FIDO still works, it doesn't type).
  # Keep in sync with home/by-host/endurance/hyprland/settings.nix.
  locker = pkgs.writeShellScript "oled-lock" ''
    ${pkgs.procps}/bin/pgrep -x hyprlock >/dev/null && exit 0
    export XKB_DEFAULT_LAYOUT=us
    export XKB_DEFAULT_VARIANT=intl
    exec ${lib.getExe pkgs.hyprlock}
  '';
in {
  # Colors (background + input-field) come from Stylix's hyprlock target (base16
  # palette, near-black base00 — OLED-cheap). Only the non-themed behaviour knobs
  # live here.
  programs.hyprlock = {
    enable = true;
    settings = {
      general.hide_cursor = true;
      # Big clock + date above the (Stylix-themed, centered) input field so the
      # lock screen isn't a bare rectangle. $TIME is a hyprlock builtin; the date
      # shells out to coreutils (absolute path — the systemd user PATH is thin).
      label = [
        {
          text = "$TIME";
          font_size = 92;
          position = "0, 220";
          halign = "center";
          valign = "center";
        }
        {
          text = ''cmd[update:60000] ${pkgs.coreutils}/bin/date +"%A, %-d. %B"'';
          font_size = 22;
          position = "0, 130";
          halign = "center";
          valign = "center";
        }
      ];
    };
  };

  services.hypridle = {
    enable = true;
    settings = {
      general = {
        lock_cmd = "${locker}";
        before_sleep_cmd = "${loginctl} lock-session";
        after_sleep_cmd = "${wakeDisplays}";
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
          on-resume = "${wakeDisplays}";
        }
      ];
    };
  };
}
