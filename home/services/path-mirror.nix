{
  config,
  lib,
  pkgs,
  ...
}:
let
  # Public tool: generic one-way rsync with online check.
  # Music library replication is Syncthing (home/services/syncthing.nix +
  # homelab hub); this CLI remains for ad-hoc one-shot copies only.
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
in
{
  home.packages = [ path-mirror ];
}
