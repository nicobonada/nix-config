{ ... }:
{
  imports = [
    ./dunst
    ./hyprland
    ./mpd
  ];

  services = {
    mpd-mpris = {
      enable = true;
      mpd.useLocal = true;
    };

    playerctld.enable = true;
    syncthing.enable = true;
    # syncthing.tray.enable = true;
    network-manager-applet.enable = true;

    gammastep = {
      enable = true;
      latitude = 43.6532;
      longitude = -79.3832;
      temperature.day = 5600;
      temperature.night = 4600;
      tray = true;
    };
  };
}
