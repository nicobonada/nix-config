{ ... }:
{
  imports = [
    ./dunst
    ./hyprland
    ./mpd
    ./wlsunset
  ];

  services = {
    mpd-mpris = {
      enable = true;
      mpd.useLocal = true;
    };

    playerctld.enable = true;
    syncthing.enable = true;
    network-manager-applet.enable = true;
  };
}
