{ inputs, pkgs, lib, config, ... }:
{
  imports = [ inputs.niri.homeModules.niri ];

  programs. niri.settings = {
    xwayland-satellite.enable = true;
    xwayland-satellite.path = lib.getExe pkgs.xwayland-satellite;

    prefer-no-csd = true;

    gestures.hot-corners.enable = false;

    input = {
      focus-follows-mouse.enable = true;

      keyboard = {
        repeat-delay = 250;
        repeat-rate = 40;
        xkb.options = "compose:caps";
      };
    };

    spawn-at-startup = [
      { sh = "type solaar >/dev/null 2>&1 && solaar -w hide"; }
      { command = [ "jamesdsp" "--tray" ]; }
      { command = [ "trilium" ]; }
      { command = [ "kitty" ]; }
      { command = [ "wayland-pipewire-idle-inhibit" ]; }
    ];

    environment = {
      APP2UNIT_TYPE = "service";
      QT_QPA_PLATFORM = "wayland";
      QT_QPA_PLATFORMTHEME = "qt6ct";
    };
  };
}
