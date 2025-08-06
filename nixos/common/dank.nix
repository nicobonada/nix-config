# { config, pkgs, lib, ... }:
{
  services.displayManager.dms-greeter = {
    enable = true;
    compositor.name = "niri";

    configHome = "/home/nico";

    logs = {
      save = true;
      path = "/var/log/dms-greeter.log";
    };
  };
}
