{ lib, ... }:
{
  imports = [
    ./mpd.nix
    ./music-backup.nix
    ./path-mirror.nix
  ];

  services = {
    kdeconnect.enable = true;
    syncthing.enable = true;
    trayscale.enable = true;

    easyeffects.enable = true;
  };
}
