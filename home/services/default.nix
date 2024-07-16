{
  imports = [
    ./dunst
    ./hyprland
    ./mpd
    ./wlsunset
  ];

  services = {
    playerctld.enable = true;
    syncthing.enable = true;
    network-manager-applet.enable = true;
  };
}
