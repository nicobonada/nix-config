{ inputs, pkgs, lib, config, ... }:
{
  imports = [ inputs.niri.homeModules.niri ];

  programs.niri.package = pkgs.niri;

  programs.niri.settings = {
    xwayland-satellite.enable = true;
    xwayland-satellite.path = lib.getExe pkgs.xwayland-satellite;

    prefer-no-csd = true;

    gestures.hot-corners.enable = false;

    input = {
      focus-follows-mouse.enable = true;

      touchpad = {
        natural-scroll = false;
        tap-button-map = "left-middle-right";
      };

      keyboard = {
        repeat-delay = 250;
        repeat-rate = 40;
        xkb.options = "compose:caps";
      };
    };

    spawn-at-startup = [
      { sh = "type solaar >/dev/null 2>&1 && app2unit -- solaar -w hide"; }
      { command = [ "jamesdsp" "--tray" ]; }
      { command = [ "trilium" ]; }
      { command = [ "kitty" ]; }
      { command = [ "wayland-pipewire-idle-inhibit" ]; }
    ];

    environment = {
      APP2UNIT_TYPE = "service";

      # hint electron apps to use wayland:
      NIXOS_OZONE_WL = "1";
      # For packages that dont yet support the above
      ELECTRON_OZONE_PLATFORM_HINT = "auto";

      QT_QPA_PLATFORM = "wayland";
      QT_QPA_PLATFORMTHEME = "qt6ct";
    };

    layout.preset-column-widths = [
      { proportion = 1. / 3.; }
      { proportion = 3. / 8.; }
      { proportion = 1. / 2.; }
      { proportion = 5. / 8.; }
      { proportion = 2. / 3.; }
    ];

    window-rules = [
      {
        matches = [ { title = "MikuLogiS\+"; } ];
        # matches = [ { app-id = "steam_app_3446190"; } ];
        open-fullscreen = false;
        open-floating = true;
      }
    ];
  };
}
