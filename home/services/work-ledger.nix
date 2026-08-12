{
  config,
  lib,
  pkgs,
  ...
}:
let
  custom = import ../../pkgs { inherit pkgs; };
  # Portable Grok definition checkout. Timer fails loudly if missing rather
  # than inventing a second copy of the script.
  workLedger = "${config.home.homeDirectory}/src/grok/scripts/work-ledger";
in
{
  # Optional interactive helpers (same as timer commands).
  home.packages = [
    custom.work-ledger
    custom.work-ledger-scan
    custom.work-ledger-weekly
  ];

  systemd.user.services.work-ledger-scan = {
    Unit = {
      Description = "Grok work ledger daily scan (sessions + unlanded VCS)";
      ConditionPathExists = workLedger;
    };
    Service = {
      Type = "oneshot";
      ExecStart = lib.getExe custom.work-ledger-scan;
      Nice = 10;
      IOSchedulingClass = "best-effort";
      IOSchedulingPriority = 7;
    };
  };

  systemd.user.timers.work-ledger-scan = {
    Unit = {
      Description = "Daily Grok work ledger scan";
      ConditionPathExists = workLedger;
    };
    Timer = {
      OnCalendar = "*-*-* 20:30:00";
      Persistent = true;
      RandomizedDelaySec = "15m";
    };
    Install = {
      WantedBy = [ "timers.target" ];
    };
  };

  systemd.user.services.work-ledger-weekly = {
    Unit = {
      Description = "Grok work ledger weekly condensed report";
      ConditionPathExists = workLedger;
    };
    Service = {
      Type = "oneshot";
      ExecStart = lib.getExe custom.work-ledger-weekly;
      Nice = 10;
      IOSchedulingClass = "best-effort";
      IOSchedulingPriority = 7;
    };
  };

  systemd.user.timers.work-ledger-weekly = {
    Unit = {
      Description = "Weekly Grok work ledger rollup";
      ConditionPathExists = workLedger;
    };
    Timer = {
      OnCalendar = "Sun *-*-* 10:00:00";
      Persistent = true;
      RandomizedDelaySec = "30m";
    };
    Install = {
      WantedBy = [ "timers.target" ];
    };
  };
}
