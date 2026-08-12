{ config, lib, ... }:
let
  # Public device IDs (not secrets). Shared home config for oakhill + seyruun:
  # seats only peer the hub (star). Hub lists both seats (homelab/syncthing.nix).
  # Folder id `music` must match on every node.
  devices = {
    homelab = {
      id = "N4ARH42-726Q7IQ-Z6ORENS-7TGCZ42-YZLOYUI-KY3FML2-BGGZX6C-CZFIUQ4";
    };
  };

  peerNames = builtins.attrNames devices;
in
{
  services.syncthing = {
    enable = true;
    guiAddress = "127.0.0.1:8384";
    # Keep declared peers/folders in sync with Nix, but do not delete other
    # folders the user manages (e.g. phone Camera). Hub uses full override.
    overrideDevices = true;
    overrideFolders = false;
    settings = {
      devices = devices;
      folders = {
        music = {
          id = "music";
          label = "music";
          # Real path is often ~/stuff/music (symlink); Syncthing follows fine.
          path = "${config.home.homeDirectory}/music";
          type = "sendreceive";
          devices = peerNames;
        };
      };
      options = {
        urAccepted = -1;
      };
    };
  };
}
