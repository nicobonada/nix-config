{
  writeShellApplication,
  syncthing,
  coreutils,
  lib,
  # Syncthing folder ids paused while beets rewrites music + DB.
  folders ? [
    "music"
    "beets-state"
  ],
}:
let
  foldersShell = lib.concatMapStringsSep " " lib.escapeShellArg folders;
in
writeShellApplication {
  name = "beets-syncthing-pause";
  runtimeInputs = [
    syncthing
    coreutils
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
}
