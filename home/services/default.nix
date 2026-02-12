{ lib, ...}:
{
  imports = [
    ./mpd.nix
  ];

  services = {
    kdeconnect.enable = true;
    syncthing.enable = true;
    trayscale.enable = true;
  };
}
