{
  config,
  pkgs,
  lib,
  ...
}:
{
  # Fumon comes from the UWSM package. Umbriel starts on its own, not as a
  # UWSM compositor.
  programs.uwsm.enable = true;

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
