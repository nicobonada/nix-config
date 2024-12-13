{ lib, ...}:
{
  imports = [
    # ./dunst
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

    swaync.enable = true;
  };

  systemd.user.services = {
    network-manager-applet.Unit.After = lib.mkForce "graphical-session.target";
    blueman-applet.Unit.After = lib.mkForce "graphical-session.target";
    kdeconnect.Unit.After = lib.mkForce "graphical-session.target";
    kdeconnect-indicator.Unit.After = lib.mkForce "graphical-session.target";
    swaync.Unit.After = lib.mkForce "graphical-session.target";
  };
}
