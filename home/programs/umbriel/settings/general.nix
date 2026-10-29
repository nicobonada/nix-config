{ host, lib, ... }:
{
  general = {
    # No bind overlay at login.
    show_cheatsheet = false;
    # X11 clients see physical pixels on the 1.25 outputs (laptop, LG).
    # Steam's own interface scale covers the client window.
    xwayland = true;
    xwayland_native_resolution = true;
    # Mod stays unset: Super on a real session, Alt when nested.
    # Autostart still focuses its targets with a launch activation token.
    autostart = [
      # Idle inhibit is a user service (home/services/idle-inhibit.nix).
      # 1Password and Steam are user services (home/services/session-tray.nix)
      # so their tray icons register after Noctalia.
      # solaar: nixos/common/solaar.nix (graphical-session; both seats)
      "kitty"
      "brave-work"
    ]
    ++ lib.optionals (host == "oakhill") [
      # Personal Brave targets the oakhill monitors.
      "brave-personal"
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
