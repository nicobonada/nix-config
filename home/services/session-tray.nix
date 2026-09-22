# These apps register a tray icon once, at startup. graphical-session.target
# stays inactive until noctalia-watcher.service sees
# org.kde.StatusNotifierWatcher on the session bus.
{ pkgs, ... }:
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
      };
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
      };
      Service = {
        ExecStart = "${pkgs.steam}/bin/steam -silent";
        Restart = "on-failure";
      };
      Install.WantedBy = [ "graphical-session.target" ];
    };
  };
}
