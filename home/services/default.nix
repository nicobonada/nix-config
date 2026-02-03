{ lib, ...}:
{
  imports = [
    ./mpd.nix
  ];

  services = {
    network-manager-applet.enable = true;
    blueman-applet.enable = true;

    kdeconnect.enable = true;
    kdeconnect.indicator = true;

    syncthing.enable = true;
    wl-clip-persist.enable = true;
  };
}
