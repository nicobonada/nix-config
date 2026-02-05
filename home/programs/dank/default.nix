{ inputs, pkgs, lib, config, ... }:
{
  imports = [
    inputs.dms.homeModules.dank-material-shell

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
    };
  };

  home.packages = with pkgs; [
    qt6Packages.qt6ct
    cliphist
    app2unit
    satty
    slurp
    wayland-pipewire-idle-inhibit
    wayscriber
    wl-screenrec
    wl-clipboard-rs # needed for emoji picker
  ];
}
