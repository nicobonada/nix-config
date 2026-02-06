{ lib, ...}:
{
  imports = [
    ./mpd.nix
  ];

  services = {
    kdeconnect.enable = true;
    syncthing.enable = true;
    tailscale-systray.enable = true;
  };
}
