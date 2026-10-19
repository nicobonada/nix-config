# home-manager's module owns Type, BusName, and ExecStart. .package is
# the swap point (this package, or haskellPackages.status-notifier-item).
# tray.target is not started in this session, so the module's WantedBy
# alone would leave the daemon idle.
{ pkgs, ... }:
let
  custom = import ../../pkgs { inherit pkgs; };
in
{
  services.status-notifier-watcher = {
    enable = true;
    package = custom.status-notifier-watcher;
  };

  systemd.user.services.status-notifier-watcher = {
    Unit = {
      # A changed unit is stop-started. This process owns the tray
      # name, and tray clients quit when that name drops. The new
      # program applies at the next login.
      X-SwitchMethod = "keep-old";
      Before = [
        "noctalia.service"
        "graphical-session.target"
      ];
      PartOf = [ "graphical-session.target" ];
    };
    Service.Restart = "no";
    Install.WantedBy = [ "graphical-session-pre.target" ];
  };
}
