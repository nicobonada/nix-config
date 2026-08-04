{ lib, ... }:
{
  imports = [
    ./mpd.nix
    ./music-backup.nix
  ];

  services = {
    kdeconnect.enable = true;
    syncthing.enable = true;
    trayscale.enable = true;

    easyeffects.enable = true;
  };
}
