{ pkgs, lib, ... }:
{
  general = {
    # No bind overlay at login.
    show_cheatsheet = false;
    # xwayland-satellite is on the wrapped umbriel PATH.
    xwayland = true;
    # Mod stays unset: Super on a real session, Alt when nested.
    # spawn: tokens still focus their target.
    autostart = [
      (lib.getExe pkgs.wayland-pipewire-idle-inhibit)
      # Personal Brave targets the oakhill monitors.
      # 1Password and Steam are user services (home/services/session-tray.nix)
      # so their tray icons register after Noctalia.
      # solaar: nixos/common/solaar.nix (graphical-session; both seats)
      "kitty"
      "brave-work"
      "[ $(hostname) = oakhill ] && brave-personal"
    ];
  };

  # Applied at session start. The Ozone hints used to ride the UWSM env
  # file that only the old session sourced.
  environment = {
    QT_QPA_PLATFORM = "wayland";
    QT_QPA_PLATFORMTHEME = "qt6ct";
    NIXOS_OZONE_WL = "1";
    ELECTRON_OZONE_PLATFORM_HINT = "auto";
  };
}
