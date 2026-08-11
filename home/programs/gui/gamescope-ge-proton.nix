{ pkgs, lib, ... }:

# Steam compatibility tool: gamescope wrapping the newest GE-Proton from
# protonup-rs (sibling dirs under compatibilitytools.d/).
#
# Order must be:  gamescope (host) → SteamLinuxRuntime → GE-Proton → game
# If gamescope runs *inside* pressure-vessel (Steam’s default when the tool
# require_tool_appid pulls SLR first), Vulkan/DRI break and games die immediately.
#
# In Steam: Settings → Compatibility → "Gamescope + GE-Proton".
# Fully quit + reopen Steam after install or toolmanifest changes.
#
# Windows / Steam Play only. Native Linux titles need launch options for gamescope.
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

  # No require_tool_appid: Steam must NOT wrap us in SLR first.
  # We invoke SteamLinuxRuntime_4 ourselves *inside* gamescope for game launches.
  home.file."${toolDir}/toolmanifest.vdf".text = ''
    "manifest"
    {
      "version" "2"
      "commandline" "/proton %verb%"
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

      steam_root="''${STEAM_COMPAT_CLIENT_INSTALL_PATH:-}"
      if [ -z "$steam_root" ]; then
        steam_root="''${HOME}/.local/share/Steam"
      fi
      slr_entry="''${steam_root}/steamapps/common/SteamLinuxRuntime_4/_v2-entry-point"
      if [ ! -x "$slr_entry" ]; then
        echo "gamescope-GE: missing SteamLinuxRuntime_4 entry point: $slr_entry" >&2
        echo "Install/update \"Steam Linux Runtime 4.0\" from Steam, then retry." >&2
        exit 1
      fi

      width=${width}
      height=${height}
      refresh=${refresh}

      # Steam invokes this tool for every Proton verb. Install-script helpers use
      # `run` (e.g. iscriptevaluator.exe) — never nest those in gamescope.
      verb="''${1:-}"
      case "$verb" in
        waitforexitandrun)
          shift
          # Host gamescope → SLR → GE-Proton → game
          # --adaptive-sync: niri enables VRR for gamescope windows (on-demand);
          # without it, mouse-look often shows horizontal tear bands that do not
          # appear in screenshots. Override via GAMESCOPE_EXTRA_ARGS if needed.
          # shellcheck disable=SC2086
          exec gamescope \
            -f \
            -W "$width" -H "$height" \
            -w "$width" -h "$height" \
            -r "$refresh" \
            --adaptive-sync \
            --force-grab-cursor \
            ''${GAMESCOPE_EXTRA_ARGS:-} \
            -- \
            "$slr_entry" --verb=waitforexitandrun -- \
            "$ge_proton/proton" waitforexitandrun "$@"
          ;;
        *)
          # Keep SLR for non-game verbs (same as stock GE-Proton dependency).
          exec "$slr_entry" --verb="$verb" -- \
            "$ge_proton/proton" "$@"
          ;;
      esac
    '';
  };
}
