{ pkgs, ... }:
{
  imports = [
    ./dunst
    ./mpd
    ./xidlehook
  ];

  services.mpdris2 = {
    enable = true;
    mpd.host = "127.0.0.1";
    notifications = true;
  };

  services.playerctld.enable = true;
  services.syncthing.enable = true;
  services.flameshot.enable = true;
  services.network-manager-applet.enable = true;

  services.gammastep = {
    enable = true;
    latitude = 43.6532;
    longitude = -79.3832;
    temperature.day = 5600;
    temperature.night = 4600;
    tray = true;
  };
}
