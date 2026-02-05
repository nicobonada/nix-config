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
        gaps 5
        struts {
          left 0
          right 0
          top 0
          bottom 0
        }


        focus-ring { width 3; }

        preset-column-widths {
          proportion 0.333333
          proportion 0.375000
          proportion 0.500000
          proportion 0.625000
          proportion 0.666667
        }
        center-focused-column "never"
      }

      output "ASUSTek COMPUTER INC VG258 MBLMQS146465" {
        mode "1920x1080@144.001"
        scale 1
        position x=731 y=0

        layout {
          gaps 0
          focus-ring { off; }
          border { off; }
          default-column-width { fixed 1920; }
        }
      }

      output "LG Electronics LG ULTRAWIDE 501NTDV76274" {
        mode "3440x1440@143.965"
        scale 1
        position x=0 y=1080
        focus-at-startup

        layout {
          struts {
            left 8
            right 8
            top 15
            bottom 15
          }

          default-column-width { proportion 0.5; }
        }
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

      // startup background and tray apps
      spawn-sh-at-startup "[ $(hostname) = 'oakhill' ] && app2unit -- solaar -w hide"
      spawn-sh-at-startup "[ $(hostname) = 'oakhill' ] && app2unit -- steam -silent"
      spawn-sh-at-startup "[ $(hostname) = 'seyruun' ] && app2unit -- mullvad-vpn"
      spawn-at-startup "jamesdsp" "--tray"
      spawn-at-startup "${lib.getExe pkgs.wayland-pipewire-idle-inhibit}"

      // startup desktop apps
      spawn-at-startup "kitty"
      spawn-at-startup "zen"
      spawn-at-startup "discord"
      spawn-at-startup "trilium"

      gestures { hot-corners { off; }; }

      xwayland-satellite { path "${lib.getExe pkgs.xwayland-satellite}"; }

      // DankMaterialShell includes
      // these files need to exist in ~/.config/niri/dms
      include "dms/alttab.kdl"
      include "dms/binds.kdl"
      include "dms/colors.kdl"
      include "dms/cursor.kdl"
      include "dms/layout.kdl"
      include "dms/outputs.kdl"
      include "dms/wpblur.kdl"

      // window rules need to be placed after the dms/layout.kdl include
      window-rule {
        match title="MikuLogiS+"
        open-fullscreen false
        open-floating true
        geometry-corner-radius 0
        clip-to-geometry false
      }

      window-rule {
        match app-id="kitty"

        default-column-width { proportion 0.333333; }
      }
    '';
  };
}
