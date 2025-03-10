{ lib, ... }:
{
  services.wlsunset = {
    enable = true;

    # Toronto
    latitude  = 43.65;
    longitude = -79.38;

    temperature = {
      day   = 5600;
      night = 4600;
    };
  };
}
