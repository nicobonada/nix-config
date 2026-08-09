{
  config,
  lib,
  pkgs,
  ...
}:
let
  home = config.home.homeDirectory;
  # Portable Grok definition checkout. Timer fails loudly if missing rather
  # than inventing a second copy of the script.
  agentRepo = "${home}/src/grok";
  workLedger = "${agentRepo}/scripts/work-ledger";

  # Thin wrappers so the unit has a real PATH (not agent-apps / not interactive
  # Grok). Script is Python stdlib + jj for VCS probes.
  mkLedgerApp =
    name: args:
    pkgs.writeShellApplication {
      inherit name;
      runtimeInputs = with pkgs; [
        python3
        jujutsu
        git
        coreutils
      ];
      text = ''
        set -euo pipefail
        script=${lib.escapeShellArg workLedger}
        if [[ ! -x $script && ! -f $script ]]; then
          echo "${name}: missing $script (clone agent-definition repo?)" >&2
          exit 1
        fi
        exec ${pkgs.python3}/bin/python3 "$script" ${args}
      '';
    };

  work-ledger-scan = mkLedgerApp "work-ledger-scan" "scan";
  work-ledger-weekly = mkLedgerApp "work-ledger-weekly" "weekly";
in
{
  # Optional interactive helpers (same as timer commands).
  home.packages = [
    work-ledger-scan
    work-ledger-weekly
    (pkgs.writeShellApplication {
      name = "work-ledger";
      runtimeInputs = with pkgs; [
        python3
        jujutsu
        git
        coreutils
      ];
      text = ''
        set -euo pipefail
        script=${lib.escapeShellArg workLedger}
        exec ${pkgs.python3}/bin/python3 "$script" "$@"
      '';
    })
  ];

  systemd.user.services.work-ledger-scan = {
    Unit = {
      Description = "Grok work ledger daily scan (sessions + unlanded VCS)";
      ConditionPathExists = workLedger;
    };
    Service = {
      Type = "oneshot";
      ExecStart = lib.getExe work-ledger-scan;
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
      ExecStart = lib.getExe work-ledger-weekly;
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
