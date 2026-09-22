# These apps register a tray icon once, at startup. Noctalia is ordered
# before graphical-session.target, so waiting for that target (and for
# noctalia.service) means the watcher already exists.
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

    trilium-desktop = {
      Unit = {
        Description = "Trilium Notes";
        After = [
          "graphical-session.target"
          "noctalia.service"
        ];
        PartOf = [ "graphical-session.target" ];
      };
      Service = {
        ExecStart = "${pkgs.trilium-desktop}/bin/trilium";
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
