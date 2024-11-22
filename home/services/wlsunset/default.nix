{ lib, ... }:
{
  services.wlsunset = {
    enable = true;

    latitude  = 43.65;
    longitude = -79.38;

    temperature = {
      day   = 5600;
      night = 4600;
    };
  };

  systemd.user.services.wlsunset.Unit.After = lib.mkForce "graphical-session.target";
}
