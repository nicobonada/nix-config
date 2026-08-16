{
  config,
  pkgs,
  lib,
  ...
}:
{
  programs.uwsm = {
    enable = true;
    waylandCompositors.niri = {
      prettyName = "Niri";
      comment = "Niri (UWSM)";
      # Prefer the current-system path so it always matches the installed binary
      binPath = "/run/current-system/sw/bin/niri-session";
    };
  };

  # Packaged fumon.service uses ExecStart=fumon (no slash). systemd on
  # NixOS only searches its own store bin for relative names → 203/EXEC.
  systemd.user.targets.graphical-session.wants = [ "fumon.service" ];
  systemd.user.services.fumon = {
    overrideStrategy = "asDropin";
    path = [ pkgs.libnotify ]; # ExecCondition: command -v notify-send
    serviceConfig.ExecStart = [
      ""
      (lib.getExe' config.programs.uwsm.package "fumon")
    ];
  };
}
