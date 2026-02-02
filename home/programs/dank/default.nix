{ inputs, pkgs, lib, config, ... }:
{
  imports = [
    inputs.dms.homeModules.dank-material-shell
    inputs.dms.homeModules.niri

    ./niri.nix
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
  };

  home.packages = with pkgs; [
    qt6Packages.qt6ct
    cliphist wl-clipboard
    app2unit
    satty
    wayland-pipewire-idle-inhibit
  ];
}
