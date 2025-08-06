{ inputs, pkgs, lib, config, ... }:
{
  imports = [
    inputs.niri.homeModules.niri
    inputs.dms.homeModules.dank-material-shell
    inputs.dms.homeModules.niri
  ];

  programs = {
    dank-material-shell = {
      enable = true;

      systemd = {
        enable = true;
        restartIfChanged = true;
      };

      # Core features
      enableSystemMonitoring = true;     # System monitoring widgets (dgop)
      enableVPN = true;                  # VPN management widget
      enableDynamicTheming = true;       # Wallpaper-based theming (matugen)
      enableAudioWavelength = true;      # Audio visualizer (cava)
      enableCalendarEvents = true;       # Calendar integration (khal)
      enableClipboardPaste = true;       # Pasting items from the clipboard (wtype)

      niri.includes.filesToInclude = [
        "alttab"                 # Please note that niri will throw an error if any of these files are missing.
        "binds"
        "colors"
        "cursor"
        "layout"
        "outputs"
        "wpblur"
      ];
    };

    niri.settings = {
      xwayland-satellite.enable = true;
      xwayland-satellite.path = lib.getExe pkgs.xwayland-satellite;

      input = {
        focus-follows-mouse.enable = true;

        keyboard = {
          repeat-delay = 250;
          repeat-rate = 40;
          xkb.options = "compose:caps";
        };
      };
    };
  };

  home.packages = with pkgs; [
    qt6Packages.qt6ct
  ];
}
