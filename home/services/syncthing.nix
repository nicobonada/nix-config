{ config, lib, ... }:
let
  # Public device IDs (not secrets). Seats peer only the hub (star).
  # Folder ids must match hub (homelab/syncthing.nix).
  devices = {
    homelab = {
      id = "N4ARH42-726Q7IQ-Z6ORENS-7TGCZ42-YZLOYUI-KY3FML2-BGGZX6C-CZFIUQ4";
    };
  };

  peerNames = builtins.attrNames devices;
  home = config.home.homeDirectory;
  beetsStateDir = "${config.xdg.dataHome}/beets-state";
in
{
  services.syncthing = {
    enable = true;
    guiAddress = "127.0.0.1:8384";
    # Do not wipe GUI folders (overrideFolders false). Hub uses full override.
    overrideDevices = true;
    overrideFolders = false;
    settings = {
      devices = devices;
      folders = {
        music = {
          id = "music";
          label = "music";
          path = "${home}/music";
          type = "sendreceive";
          devices = peerNames;
        };
        beets-state = {
          id = "beets-state";
          label = "beets-state";
          path = beetsStateDir;
          type = "sendreceive";
          devices = peerNames;
        };
      };
      options = {
        urAccepted = -1;
      };
    };
  };

  # Ensure local path exists before first Syncthing scan.
  home.activation.beetsStateDir = config.lib.dag.entryAfter [ "writeBoundary" ] ''
    mkdir -p ${lib.escapeShellArg beetsStateDir}
  '';
}
