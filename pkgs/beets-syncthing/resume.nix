{
  writeShellApplication,
  syncthing,
  coreutils,
  lib,
  folders ? [
    "music"
    "beets-state"
  ],
}:
let
  foldersShell = lib.concatMapStringsSep " " lib.escapeShellArg folders;
in
writeShellApplication {
  name = "beets-syncthing-resume";
  runtimeInputs = [
    syncthing
    coreutils
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
}
