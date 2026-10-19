# These apps register a tray icon once, at startup. They follow
# graphical-session.target, which waits for noctalia.service.
# noctalia.service waits for status-notifier-watcher.service. That unit
# is Type=dbus, so the bus name is owned before these apps start.
#
# sd-switch starts any inactive unit wanted by an active target, so a home
# switch relaunches an app whose main process has exited. Trilium did that
# on every switch. Refuse manual start and stop: the session target still
# pulls them in at login, PartOf still stops them at logout, and a switch
# leaves a running instance alone.
{
  host,
  lib,
  pkgs,
  ...
}:
let
  sessionOnly = {
    RefuseManualStart = true;
    RefuseManualStop = true;
  };
in
{
  systemd.user.services = lib.mkMerge [
    {
      onepassword = {
        Unit = {
          Description = "1Password";
          After = [
            "graphical-session.target"
            "noctalia.service"
          ];
          PartOf = [ "graphical-session.target" ];
        }
        // sessionOnly;
        Service = {
          ExecStart = "${pkgs._1password-gui}/bin/1password";
          Restart = "on-failure";
        };
        Install.WantedBy = [ "graphical-session.target" ];
      };
    }
    # oakhill only. The seyruun home config does not define this unit.
    (lib.mkIf (host == "oakhill") {
      steam-client = {
        Unit = {
          Description = "Steam";
          After = [
            "graphical-session.target"
            "noctalia.service"
          ];
          PartOf = [ "graphical-session.target" ];
        }
        // sessionOnly;
        Service = {
          ExecStart = "${pkgs.steam}/bin/steam -silent";
          Restart = "on-failure";
        };
        Install.WantedBy = [ "graphical-session.target" ];
      };
    })
  ];
}
