{ pkgs, lib, ... }:

# Steam compatibility tool: gamescope wrapping the newest GE-Proton from
# protonup-rs (sibling dirs under compatibilitytools.d/).
#
# In Steam: Settings → Compatibility → set default (or per-game) to
# "Gamescope + GE-Proton". Fully quit + reopen Steam after first install.
#
# Only Windows titles via Steam Play (same scope as GE-Proton). Native Linux
# builds need per-game launch options if you want gamescope.
let
  width = "3440";
  height = "1440";
  refresh = "160";
  toolDir = ".local/share/Steam/compatibilitytools.d/gamescope-GE";
  path = lib.makeBinPath [
    pkgs.gamescope
    pkgs.coreutils
    pkgs.findutils
  ];
in
{
  home.file."${toolDir}/compatibilitytool.vdf".text = ''
    "compatibilitytools"
    {
      "compat_tools"
      {
        "gamescope-GE"
        {
          "install_path" "."
          "display_name" "Gamescope + GE-Proton"
          "from_oslist"  "windows"
          "to_oslist"    "linux"
        }
      }
    }
  '';

  # Match GE-Proton so Steam still pulls the same SLR / session layer.
  home.file."${toolDir}/toolmanifest.vdf".text = ''
    "manifest"
    {
      "version" "2"
      "commandline" "/proton %verb%"
      "require_tool_appid" "4183110"
      "use_sessions" "1"
      "compatmanager_layer_name" "proton"
    }
  '';

  # Real file in the tool dir (not a store symlink) so dirname "$0" finds GE-Proton*.
  home.file."${toolDir}/proton" = {
    executable = true;
    text = ''
      #!${pkgs.runtimeShell}
      set -euo pipefail
      export PATH="${path}:''${PATH:-}"

      tool_dir="$(cd "$(dirname "$0")" && pwd)"
      compat_root="$(cd "$tool_dir/.." && pwd)"

      ge_proton=""
      if ls -1d "$compat_root"/GE-Proton* >/dev/null 2>&1; then
        ge_proton="$(ls -1d "$compat_root"/GE-Proton* | sort -V | tail -n1)"
      fi
      if [ -z "$ge_proton" ] || [ ! -x "$ge_proton/proton" ]; then
        echo "gamescope-GE: no GE-Proton*/proton under $compat_root" >&2
        echo "Install GE-Proton with protonup-rs, then restart Steam." >&2
        exit 1
      fi

      width=${width}
      height=${height}
      refresh=${refresh}

      # Steam invokes this tool for *every* Proton verb, including install-script
      # helpers (iscriptevaluator.exe via `run`). Nesting those in gamescope
      # hangs the "LAUNCHING…" UI forever. Only wrap the real game launch.
      verb="''${1:-}"
      case "$verb" in
        waitforexitandrun)
          shift
          # Optional: GAMESCOPE_EXTRA_ARGS='--hdr-enabled' …
          # shellcheck disable=SC2086
          exec gamescope \
            -f \
            -W "$width" -H "$height" \
            -w "$width" -h "$height" \
            -r "$refresh" \
            --force-grab-cursor \
            ''${GAMESCOPE_EXTRA_ARGS:-} \
            -- \
            "$ge_proton/proton" waitforexitandrun "$@"
          ;;
        *)
          exec "$ge_proton/proton" "$@"
          ;;
      esac
    '';
  };
}
