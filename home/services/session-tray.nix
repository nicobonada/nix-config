# These apps register a tray icon once, at startup. graphical-session.target
# stays inactive until noctalia-watcher.service sees
# org.kde.StatusNotifierWatcher on the session bus.
#
# sd-switch starts any inactive unit wanted by an active target, so a home
# switch relaunches an app whose main process has exited. Trilium did that
# on every switch. Refuse manual start and stop: the session target still
# pulls them in at login, PartOf still stops them at logout, and a switch
# leaves a running instance alone.
{ pkgs, ... }:
let
  sessionOnly = {
    RefuseManualStart = true;
    RefuseManualStop = true;
  };
in
{
  systemd.user.services = {
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

    # oakhill only. ConditionHost skips the start on other seats.
    steam-client = {
      Unit = {
        Description = "Steam";
        After = [
          "graphical-session.target"
          "noctalia.service"
        ];
        PartOf = [ "graphical-session.target" ];
        ConditionHost = "oakhill";
      }
      // sessionOnly;
      Service = {
        ExecStart = "${pkgs.steam}/bin/steam -silent";
        Restart = "on-failure";
      };
      Install.WantedBy = [ "graphical-session.target" ];
    };
  };
}
