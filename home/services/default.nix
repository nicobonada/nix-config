{ lib, ...}:
{
  imports = [
    # ./hyprland
    ./mpd
    ./wlsunset
  ];

  services = {
    syncthing.enable = true;
    network-manager-applet.enable = true;
    blueman-applet.enable = true;

    kdeconnect.enable = true;
    kdeconnect.indicator = true;

    # swaync.enable = true;
    wl-clip-persist.enable = true;
  };
}
