{ inputs, pkgs, lib, config, ... }:
{
  imports = [ inputs.niri-nix.homeModules.default ];

  wayland.windowManager.niri = {
    enable = true;

    extraConfig = /* kdl */ ''
      input {
        keyboard {
          xkb {
            options "compose:caps"
          }

          repeat-delay 250
          repeat-rate 40
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
        mode "1920x1080@60.000"
        scale 1
        position x=731 y=0
        variable-refresh-rate on-demand=true

        layout {
          gaps 0
          focus-ring { off; }
          border { off; }
          default-column-width { fixed 1920; }
        }
      }

      output "LG Electronics LG ULTRAWIDE 501NTDV76274" {
        mode "3440x1440@159.962"
        scale 1
        position x=0 y=1080
        focus-at-startup
        variable-refresh-rate on-demand=true

        layout {
          struts {
            left 8
            right 8
            top 15
            bottom 15
          }
        }
      }

      cursor {
        xcursor-theme "Bibata-Modern-Ice"
        xcursor-size 24
      }

      environment {
        "QT_QPA_PLATFORM" "wayland"
        "QT_QPA_PLATFORMTHEME" "qt6ct"
      }

      spawn-at-startup "noctalia"

      // startup background and tray apps
      spawn-sh-at-startup "[ $(hostname) = 'oakhill' ] && app2unit -- solaar -w hide"
      spawn-sh-at-startup "[ $(hostname) = 'oakhill' ] && app2unit -- steam -silent"
      spawn-at-startup "${lib.getExe pkgs.wayland-pipewire-idle-inhibit}"

      // startup desktop apps
      spawn-at-startup "kitty"
      spawn-at-startup "zen"
      spawn-at-startup "discord"
      spawn-at-startup "trilium"

      gestures { hot-corners { off; }; }

      xwayland-satellite { path "${lib.getExe pkgs.xwayland-satellite}"; }

      // // DankMaterialShell includes
      // // these files need to exist in ~/.config/niri/dms
      // include "dms/alttab.kdl"
      include "dms/binds.kdl"

      binds {
        // Core Noctalia binds
        Mod+Space { spawn-sh "noctalia msg panel-toggle launcher"; }
        Mod+S { spawn-sh "noctalia msg panel-toggle control-center"; }
        Mod+Comma { spawn-sh "noctalia msg settings-toggle"; }

        // Audio & Brightness
        XF86AudioRaiseVolume { spawn-sh "noctalia msg volume-up"; }
        XF86AudioLowerVolume { spawn-sh "noctalia msg volume-down"; }
        XF86AudioMute { spawn-sh "noctalia msg volume-mute"; }
        XF86MonBrightnessUp { spawn-sh "noctalia msg brightness-up"; }
        XF86MonBrightnessDown { spawn-sh "noctalia msg brightness-down"; }
      }
      // include "dms/colors.kdl"
      // include "dms/cursor.kdl"
      // include "dms/layout.kdl"
      // include "dms/outputs.kdl"
      // include "dms/windowrules.kdl"
      // include "dms/wpblur.kdl"

      // window rules need to be placed after the dms/layout.kdl include

      window-rule {
        open-floating false
      }

      window-rule {
        match app-id=r#"steam_app_\d+"#

        open-fullscreen true
        variable-refresh-rate true
        open-floating true
        geometry-corner-radius 0
        clip-to-geometry false
      }

      // Hatsune Miku Logic Paint S+ only supports 1920x800 (?)
      window-rule {
        match title="MikuLogiS+"

        open-fullscreen false
      }

      // terminal
      window-rule {
        match app-id="^kitty$"
        default-column-width { proportion 0.333333; }
      }

      // this should hopefully only match dms windows
      window-rule {
        match app-id="^org.quickshell$"
        default-column-width { fixed 925; }
      }

      // don't open steam notifications in the center of the screen
      window-rule {
        match app-id="steam" title=r#"^notificationtoasts_\d+_desktop$"#
        default-floating-position x=10 y=10 relative-to="bottom-right"
      }

      window-rule {
        match app-id="discord"
        default-column-width { proportion 0.375000; }
      }

      // block out sensitive components from screencasts
      layer-rule {
        match namespace="^dms:clipboard$"
        match namespace="^dms:notification"

        block-out-from "screencast"
      }

      // Noctalia settings
      window-rule {
        // Rounded corners for a modern look.
        geometry-corner-radius 8

        // Clips window contents to the rounded corner boundaries.
        clip-to-geometry true
      }

      // Floating Noctalia settings window.
      window-rule {
        match app-id="dev.noctalia.Noctalia.Settings"
        open-floating true
        default-column-width { fixed 1080; }
        default-window-height { fixed 920; }
      }

      debug {
        // Allows notification actions and window activation from Noctalia.
        honor-xdg-activation-with-invalid-serial
      }

      // blurred overview wallpaper
      // requires the [niri/backdrop] section to be enabled in your Noctalia configuration.
      layer-rule {
        match namespace="^noctalia-backdrop"
        place-within-backdrop true
      }

      //blur
      /* Apps: blur them all without xray so it looks more realistic. */
      window-rule {
        background-effect {
          blur true
          xray false
        }
      }

      /*
        Noctalia
        Disable xray on all our surfaces so it looks more realistic.
        Noctalia publishes blur regions automatically when ext-background-effects is available.
      */
      layer-rule {
        match namespace="^noctalia-(bar-[^\"]+|notification|dock|panel|attached-panel|osd)$"
        background-effect {
          xray false
          // blur false
        }
      }

      /* You can also fine-tune the blur effect globally. */
      blur {
        passes 2        // more passes = stronger blur (default: 3)
        offset 3.0      // sample distance per pass (default: 3.0)
        noise 0.03      // grain overlay (default: 0.02)
        saturation 1.0  // color saturation boost (default: 1.5)
      }
    '';
  };
}
