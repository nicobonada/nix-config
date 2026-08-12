{ config, lib, pkgs, ... }:
let
  # Pause/resume Syncthing folders while beets rewrites music + DB.
  # Used by: nix develop .#beets (shellHook + EXIT trap).
  folders = [
    "music"
    "beets-state"
  ];
  foldersShell = lib.concatMapStringsSep " " lib.escapeShellArg folders;

  beetsLiveLegacy = "${config.home.homeDirectory}/.config/beets";
  beetsStateDir = "${config.xdg.dataHome}/beets-state";

  beets-syncthing-pause = pkgs.writeShellApplication {
    name = "beets-syncthing-pause";
    runtimeInputs = [
      pkgs.syncthing
      pkgs.coreutils
    ];
    text = ''
      # Pause music + beets-state so imports do not half-sync.
      # Refcount: nested beets shells only resume when the last exits.
      set -euo pipefail
      runtime="''${XDG_RUNTIME_DIR:-/tmp}"
      ref="$runtime/beets-syncthing.ref"
      mkdir -p "$runtime"
      count=0
      if [[ -f $ref ]]; then
        count=$(cat "$ref" 2>/dev/null || echo 0)
      fi
      count=$((count + 1))
      echo "$count" >"$ref"
      if [[ $count -gt 1 ]]; then
        echo "beets-syncthing-pause: nested ($count); already paused" >&2
        exit 0
      fi
      for folder in ${foldersShell}; do
        if syncthing cli config folders list 2>/dev/null | grep -qx "$folder"; then
          syncthing cli config folders "$folder" paused set true
          echo "beets-syncthing-pause: paused $folder" >&2
        else
          echo "beets-syncthing-pause: skip missing folder $folder" >&2
        fi
      done
    '';
  };

  beets-syncthing-resume = pkgs.writeShellApplication {
    name = "beets-syncthing-resume";
    runtimeInputs = [
      pkgs.syncthing
      pkgs.coreutils
    ];
    text = ''
      set -euo pipefail
      runtime="''${XDG_RUNTIME_DIR:-/tmp}"
      ref="$runtime/beets-syncthing.ref"
      count=1
      if [[ -f $ref ]]; then
        count=$(cat "$ref" 2>/dev/null || echo 1)
      fi
      if [[ $count -gt 1 ]]; then
        count=$((count - 1))
        echo "$count" >"$ref"
        echo "beets-syncthing-resume: nested remaining $count; still paused" >&2
        exit 0
      fi
      rm -f "$ref"
      for folder in ${foldersShell}; do
        if syncthing cli config folders list 2>/dev/null | grep -qx "$folder"; then
          syncthing cli config folders "$folder" paused set false
          echo "beets-syncthing-resume: resumed $folder" >&2
        else
          echo "beets-syncthing-resume: skip missing folder $folder" >&2
        fi
      done
    '';
  };

  beets-state-migrate = pkgs.writeShellApplication {
    name = "beets-state-migrate";
    runtimeInputs = with pkgs; [ coreutils ];
    text = ''
      # Move legacy ~/.config/beets/{library.db,state.pickle} into the
      # Syncthing beets-state folder once. Safe to re-run.
      set -euo pipefail
      dest=${lib.escapeShellArg beetsStateDir}
      legacy=${lib.escapeShellArg beetsLiveLegacy}
      mkdir -p "$dest"
      for f in library.db state.pickle; do
        if [[ -f $legacy/$f && ! -e $dest/$f ]]; then
          mv -n "$legacy/$f" "$dest/$f"
          echo "beets-state-migrate: moved $f → $dest/"
        elif [[ -e $dest/$f ]]; then
          echo "beets-state-migrate: keep existing $dest/$f"
        else
          echo "beets-state-migrate: no $legacy/$f (ok)"
        fi
      done
    '';
  };
in
{
  home.packages = [
    beets-syncthing-pause
    beets-syncthing-resume
    beets-state-migrate
  ];

  # One-shot on activation so first Syncthing scan has a real DB (idempotent).
  home.activation.beetsStateMigrate = config.lib.dag.entryAfter [ "beetsStateDir" ] ''
    ${lib.getExe beets-state-migrate}
  '';
}
