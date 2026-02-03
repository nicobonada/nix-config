{ lib, ...}:
{
  imports = [
    ./mpd.nix
  ];

  services = {
    kdeconnect.enable = true;
    kdeconnect.indicator = true;

    syncthing.enable = true;
  };
}
