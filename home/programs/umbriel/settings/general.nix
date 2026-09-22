{ pkgs, lib, ... }:
{
  general = {
    # Niri does not pop a bind overlay at login.
    show_cheatsheet = false;
    # xwayland-satellite is on the wrapped umbriel PATH.
    xwayland = true;
    # Mod stays unset: Super on a real session, Alt when nested. Same idea as
    # niri's Mod. Niri's honor-xdg-activation-with-invalid-serial has no
    # Umbriel switch; spawn: tokens still focus their target.
    autostart = [
      (lib.getExe pkgs.wayland-pipewire-idle-inhibit)
      # Personal Brave targets the oakhill monitors.
      # niri-game-output speaks niri IPC, so it stays on that session.
      # 1Password and Steam are user services (home/services/session-tray.nix)
      # so their tray icons register after Noctalia.
      "kitty"
      "brave-work"
      "[ $(hostname) = oakhill ] && brave-personal"
    ];
  };

  # Same pair niri exported. Applied at session start.
  environment = {
    QT_QPA_PLATFORM = "wayland";
    QT_QPA_PLATFORMTHEME = "qt6ct";
  };
}
