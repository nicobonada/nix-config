{ lib, ...}:
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
    blueman-applet.enable = true;

    kdeconnect.enable = true;
    kdeconnect.indicator = true;

  };

  systemd.user.services.network-manager-applet.Unit.After = lib.mkForce "graphical-session.target";
  systemd.user.services.blueman-applet.Unit.After = lib.mkForce "graphical-session.target";
  systemd.user.services.kdeconnect.Unit.After = lib.mkForce "graphical-session.target";
  systemd.user.services.kdeconnect-indicator.Unit.After = lib.mkForce "graphical-session.target";
}
