{
  writeShellApplication,
  jq,
}:
# Move Steam / gamescope windows onto the ultrawide after app-id arrives.
#
# niri open-on-output cannot: it runs at first configure, before Proton
# sets steam_app_*. VRR / corner radius stay on the window-rule
# (home/programs/gui/niri-rules.kdl). This only fixes placement.
#
#   niri msg --json event-stream
#           │
#           ├─ WindowOpenedOrChanged / WindowsChanged
#           │     app-id is steam_app_* or gamescope
#           │     workspace is not the LG
#           │       → niri msg action move-window-to-monitor --id <id> <LG>
#           │       → niri msg action focus-window --id <id>
#           └─ later events for the same window → ignore (do not yank it back)
#
# Session niri is on PATH (matches the compositor). jq is the only extra input.
writeShellApplication {
  name = "niri-game-output";
  runtimeInputs = [ jq ];
  text = ''
    target_name="LG Electronics LG ULTRAWIDE 501NTDV76274"

    while [[ $# -gt 0 ]]; do
      case "$1" in
        --output)
          target_name=$2
          shift 2
          ;;
        -h | --help)
          echo "usage: niri-game-output [--output NAME]" >&2
          exit 0
          ;;
        *)
          echo "usage: niri-game-output [--output NAME]" >&2
          exit 2
          ;;
      esac
    done

    # Workspace events name the connector (DP-2), not make/model/serial.
    # Retry briefly: spawn-at-startup can beat the first outputs snapshot.
    # Empty after retries = unplugged; same fallback as the window rule.
    connector=
    for _ in 1 2 3 4 5 6 7 8 9 10; do
      # outputs JSON is { "DP-2": { name, make, model, serial, … }, … }.
      # --arg n binds $n. to_entries[] walks each connector. select keeps a
      # match. .key is DP-2 (workspace events use that, not make/model).
      if connector=$(niri msg --json outputs 2>/dev/null | jq -r --arg n "$target_name" '
        to_entries[]
        | select(
            .key == $n
            or .value.name == $n
            or ([.value.make, .value.model, .value.serial] | join(" ")) == $n
          )
        | .key
      ') && [[ -n $connector ]]; then
        break
      fi
      sleep 0.5
    done
    if [[ -z $connector ]]; then
      exit 0
    fi

    declare -A moved=()

    is_game() {
      [[ $1 =~ ^steam_app_[0-9]+$ || $1 == gamescope ]]
    }

    # Live lookup so we do not keep a stale workspace→output map.
    # --argjson id makes $id a number (workspace ids are ints). // empty
    # turns JSON null into "" so bash sees a blank.
    connector_for_workspace() {
      niri msg --json workspaces | jq -r --argjson id "$1" '
        .[] | select(.id == $id) | .output // empty
      '
    }

    consider() {
      local id=$1 app=$2 ws=$3
      local out

      [[ -n $id ]] || return 0
      [[ -z ''${moved[$id]+x} ]] || return 0
      is_game "$app" || return 0
      # Not placed yet — wait for the next WindowOpenedOrChanged.
      [[ -n $ws ]] || return 0

      out=$(connector_for_workspace "$ws")
      if [[ $out == "$connector" ]]; then
        moved[$id]=1
        return 0
      fi

      niri msg action move-window-to-monitor --id "$id" "$target_name" || return 0
      niri msg action focus-window --id "$id" || true
      moved[$id]=1
    }

    # Process substitution keeps `moved` in this shell (not a pipe subshell).
    while IFS= read -r line; do
      [[ -n $line ]] || continue
      # Event objects have one key: {"WindowOpenedOrChanged":{…}}. keys[0] is that name.
      kind=$(jq -r 'keys[0]' <<<"$line") || continue
      case $kind in
        WindowsChanged)
          # .[] walks each window. [a,b,c] | @tsv prints tab-separated fields
          # (safe: ids/app-ids have no tabs). // "" fills missing app_id/workspace.
          while IFS=$'\t' read -r id app ws; do
            consider "$id" "$app" "$ws"
          done < <(jq -r '
            .WindowsChanged.windows[]
            | [.id, (.app_id // ""), (.workspace_id // "")]
            | @tsv
          ' <<<"$line")
          ;;
        WindowOpenedOrChanged)
          IFS=$'\t' read -r id app ws < <(jq -r '
            .WindowOpenedOrChanged.window
            | [.id, (.app_id // ""), (.workspace_id // "")]
            | @tsv
          ' <<<"$line")
          consider "$id" "$app" "$ws"
          ;;
        WindowClosed)
          unset "moved[$(jq -r '.WindowClosed.id' <<<"$line")]"
          ;;
      esac
    done < <(niri msg --json event-stream)
  '';
}
