{ inputs, pkgs, lib, config, ... }:
{
  imports = [ inputs.niri-nix.homeModules.default ];

  wayland.windowManager.niri = {
    enable = true;

    extraConfig = /* kdl */ ''
      input {
          keyboard {
              xkb {
                  layout ""
                  model ""
                  rules ""
                  variant ""
                  options "compose:caps"
              }
              repeat-delay 250
              repeat-rate 40
              track-layout "global"
          }
          touchpad {
              tap
              tap-button-map "left-middle-right"
          }
          focus-follows-mouse
      }

      screenshot-path "~/Pictures/Screenshots/Screenshot from %Y-%m-%d %H-%M-%S.png"

      prefer-no-csd

      layout {
          gaps 16
          struts {
              left 0
              right 0
              top 0
              bottom 0
          }
          focus-ring { width 4; }
          border { off; }
          default-column-width
          preset-column-widths {
              proportion 0.333333
              proportion 0.375000
              proportion 0.500000
              proportion 0.625000
              proportion 0.666667
          }
          center-focused-column "never"
      }

      cursor {
          xcursor-theme "default"
          xcursor-size 24
      }

      environment {
          "APP2UNIT_TYPE" "service"
          "ELECTRON_OZONE_PLATFORM_HINT" "auto"
          "NIXOS_OZONE_WL" "1"
          "QT_QPA_PLATFORM" "wayland"
          "QT_QPA_PLATFORMTHEME" "qt6ct"
      }

      spawn-sh-at-startup "type solaar >/dev/null 2>&1 && app2unit -- solaar -w hide"
      spawn-at-startup "jamesdsp" "--tray"
      spawn-at-startup "trilium"
      spawn-at-startup "kitty"
      spawn-at-startup "wayland-pipewire-idle-inhibit"

      gestures { hot-corners { off; }; }
 
      xwayland-satellite { path "${lib.getExe pkgs.xwayland-satellite}"; }

      include "dms/alttab.kdl"
      include "dms/binds.kdl"
      include "dms/colors.kdl"
      include "dms/cursor.kdl"
      include "dms/layout.kdl"
      include "dms/outputs.kdl"
      include "dms/wpblur.kdl"

      window-rule {
        match title="MikuLogiS+"
        open-fullscreen false
        open-floating true
        geometry-corner-radius 0
        clip-to-geometry false
      }
    '';
  };
}
