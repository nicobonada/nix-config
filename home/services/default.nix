{ pkgs, ... }:
{
  imports = [
    ./beets-syncthing-scripts.nix
    ./idle-inhibit.nix
    ./mpd.nix
    ./pass-secret-service.nix
    ./path-mirror.nix
    ./pipewire.nix
    ./session-tray.nix
    ./shpool.nix
    ./status-notifier-watcher.nix
    ./syncthing.nix
    ./trilium-server.nix
  ];

  services = {
    kdeconnect.enable = true;
    # Output EQ is the PipeWire chains in pipewire.nix.
    easyeffects.enable = false;
  };

  # Phone Connect lists devices with `gdbus`. kdeconnect ships the daemon
  # and CLI only; without glib on PATH the widget stays on "No devices".
  home.packages = [ pkgs.glib ];
}
