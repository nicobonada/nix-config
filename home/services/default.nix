{ pkgs, ... }:
{
  imports = [
    ./beets-syncthing-scripts.nix
    ./mpd.nix
    ./path-mirror.nix
    ./pipewire.nix
    ./session-tray.nix
    ./syncthing.nix
    ./trilium-server.nix
  ];

  services = {
    kdeconnect.enable = true;
    easyeffects.enable = true;
  };

  # Phone Connect lists devices with `gdbus`. kdeconnect ships the daemon
  # and CLI only; without glib on PATH the widget stays on "No devices".
  home.packages = [ pkgs.glib ];
}
