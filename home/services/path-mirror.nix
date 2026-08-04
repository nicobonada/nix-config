{
  config,
  lib,
  pkgs,
  ...
}:
let
  home = config.home.homeDirectory;
  musicDir = "${home}/music";
  beetsDb = "${home}/.config/beets/library.db";
  beetsState = "${home}/.config/beets/state.pickle";
  beetsStaging = "${config.xdg.dataHome}/beets-mirror";

  # Spare host for the timer; override for one shot: MEDIA_MIRROR_REMOTE=host …
  # or call path-mirror directly with any host:path.
  defaultRemote = "oakhill";

  # Public tool: generic one-way rsync with online check.
  path-mirror = pkgs.writeShellApplication {
    name = "path-mirror";
    runtimeInputs = with pkgs; [
      openssh
      rsync
      coreutils
    ];
    text = ''
      # One-way rsync when the destination host is up.
      #
      # Usage:
      #   path-mirror [--delete|--no-delete] SRC DEST
      #
      # DEST forms:
      #   host:path   — SSH/rsync remote (e.g. oakhill:music/)
      #   /local/path — local only (no host probe)
      #
      # Behaviour:
      #   - host:path and host unreachable → exit 0 (skip)
      #   - SRC missing → exit 0 (skip)
      #   - dir SRC: --delete by default (DEST matches SRC); --no-delete to only add/update
      #   - file SRC: never --delete
      set -euo pipefail

      delete=auto
      while [[ $# -gt 0 ]]; do
        case "$1" in
          --delete) delete=yes; shift ;;
          --no-delete) delete=no; shift ;;
          -h|--help)
            sed -n '2,20p' "$0" | sed 's/^# \?//'
            exit 0
            ;;
          --) shift; break ;;
          -*)
            echo "path-mirror: unknown option: $1" >&2
            exit 2
            ;;
          *) break ;;
        esac
      done

      if [[ $# -ne 2 ]]; then
        echo "usage: path-mirror [--delete|--no-delete] SRC DEST" >&2
        exit 2
      fi

      src=$1
      dest=$2

      if [[ ! -e $src ]]; then
        echo "path-mirror: missing source $src (skip)" >&2
        exit 0
      fi

      host=
      remote_path=
      if [[ $dest == *:* && $dest != /*:* ]]; then
        host=''${dest%%:*}
        remote_path=''${dest#*:}
      fi

      if [[ -n $host ]]; then
        if ! ssh \
          -o BatchMode=yes \
          -o ConnectTimeout=5 \
          -o ConnectionAttempts=1 \
          "$host" true 2>/dev/null; then
          echo "path-mirror: $host not reachable (skip)" >&2
          exit 0
        fi
        if [[ $remote_path == */* ]]; then
          parent=''${remote_path%/*}
          if [[ -n $parent && $parent != "$remote_path" ]]; then
            ssh -o BatchMode=yes -o ConnectTimeout=5 "$host" \
              "mkdir -p -- $(printf '%q' "$parent")"
          fi
        fi
      fi

      rsync_opts=(-aH --partial --timeout=60 --info=stats2)
      if [[ -d $src ]]; then
        if [[ $delete == auto || $delete == yes ]]; then
          rsync_opts+=(--delete)
        fi
      elif [[ $delete == yes ]]; then
        echo "path-mirror: ignoring --delete for file source" >&2
      fi

      rsync "''${rsync_opts[@]}" "$src" "$dest"
      echo "path-mirror: $src → $dest"
    '';
  };

  # Private orchestrator for the timer only (not on PATH). Policy lives here;
  # path-mirror stays the reusable tool when you buy a new machine.
  media-mirror-job = pkgs.writeShellApplication {
    name = "media-mirror-job";
    runtimeInputs = [
      path-mirror
      pkgs.openssh
      pkgs.sqlite
      pkgs.coreutils
    ];
    text = ''
      # Scheduled pairs → spare host (default oakhill).
      #   ~/music/     → REMOTE:music/   (--delete)
      #   beets DB     → REMOTE:.config/beets/library.db  (sqlite .backup first)
      #   state.pickle → REMOTE:.config/beets/state.pickle
      # MEDIA_MIRROR_REMOTE=newhost to retarget without editing Nix.
      set -euo pipefail

      remote=''${MEDIA_MIRROR_REMOTE:-${defaultRemote}}
      music=${lib.escapeShellArg musicDir}
      live_db=${lib.escapeShellArg beetsDb}
      state=${lib.escapeShellArg beetsState}
      staging=${lib.escapeShellArg beetsStaging}

      if ! ssh \
        -o BatchMode=yes \
        -o ConnectTimeout=5 \
        -o ConnectionAttempts=1 \
        "$remote" true 2>/dev/null; then
        echo "media-mirror-job: $remote not reachable (skip)" >&2
        exit 0
      fi

      if [[ -d $music ]]; then
        path-mirror --delete "$music"/ "$remote:music/"
      else
        echo "media-mirror-job: no $music (skip music)" >&2
      fi

      mkdir -p "$staging"
      chmod 700 "$staging"
      if [[ -f $live_db ]]; then
        sqlite3 "$live_db" ".backup '$staging/library.db'"
        path-mirror --no-delete "$staging/library.db" "$remote:.config/beets/library.db"
      else
        echo "media-mirror-job: no beets DB (skip)" >&2
      fi

      if [[ -f $state ]]; then
        path-mirror --no-delete "$state" "$remote:.config/beets/state.pickle"
      fi

      echo "media-mirror-job: finished → $remote"
    '';
  };
in
{
  # Only the generic tool on PATH; the job is systemd-only.
  home.packages = [ path-mirror ];

  systemd.user.services.media-mirror = {
    Unit = {
      Description = "One-way mirror of music + beets to spare host when online";
      Wants = [ "network-online.target" ];
      After = [ "network-online.target" ];
      ConditionPathIsDirectory = musicDir;
    };
    Service = {
      Type = "oneshot";
      ExecStart = lib.getExe media-mirror-job;
      Nice = 10;
      IOSchedulingClass = "best-effort";
      IOSchedulingPriority = 7;
    };
  };

  systemd.user.timers.media-mirror = {
    Unit = {
      Description = "Try media mirror when spare host may be up";
      ConditionPathIsDirectory = musicDir;
    };
    Timer = {
      OnCalendar = "*:0/30";
      Persistent = true;
      RandomizedDelaySec = "5m";
    };
    Install = {
      WantedBy = [ "timers.target" ];
    };
  };
}
