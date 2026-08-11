{ pkgs, ... }:

# Optional: restart Steam inside gamescope (-e Steam integration) so every game
# inherits the nest without per-title launch options.
#
# Not a Steam library hack — Steam has no global %command% wrapper. If desktop
# Steam is already running (e.g. niri silent startup), a second `steam` only
# focuses it *outside* gamescope; this script shuts that down first.
let
  steam-gamescope = pkgs.writeShellApplication {
    name = "steam-gamescope";
    runtimeInputs = with pkgs; [
      gamescope
      steam
      procps
      coreutils
    ];
    text = ''
      # LG ultrawide panel (physical). Host niri scale is 1.25 → logical
      # 2752×1152; gamescope still targets panel-native for the nest.
      width=3440
      height=1440
      refresh=160

      if pgrep -x steam >/dev/null 2>&1; then
        echo "steam-gamescope: shutting down desktop Steam so it can restart under gamescope…"
        steam -shutdown || true
        # Wait up to ~20s for clean exit (downloads / friends list can lag).
        for _ in $(seq 1 40); do
          pgrep -x steam >/dev/null 2>&1 || break
          sleep 0.5
        done
        if pgrep -x steam >/dev/null 2>&1; then
          echo "steam-gamescope: Steam still running; refusing to double-launch" >&2
          exit 1
        fi
      fi

      # -e: Steam integration (games stay inside this nest)
      # -f: fullscreen on the focused output
      # No --force-grab-cursor: that locks the mouse for the whole Steam UI.
      exec gamescope \
        -e \
        -f \
        -W "$width" -H "$height" \
        -w "$width" -h "$height" \
        -r "$refresh" \
        -- \
        steam "$@"
    '';
  };
in
{
  home.packages = [ steam-gamescope ];
}
