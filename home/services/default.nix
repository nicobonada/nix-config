{ lib, ... }:
{
  imports = [
    ./mpd.nix
    ./music-backup.nix
    ./path-mirror.nix
    ./trilium-server.nix
  ];

  services = {
    kdeconnect.enable = true;
    syncthing.enable = true;
    trayscale.enable = true;

    easyeffects.enable = true;

    # Always-on Trilium for Grok MCP; separate dataDir from Electron desktop.
    # Always-on MCP/web; separate dataDir from Electron.
    # Password: sops secrets/trilium.yaml → trilium.document_password (not CHANGE_ME).
    trilium-server = {
      enable = true;
      sync.serverHost = "https://nico-notes.pikapod.net";
      bootstrap.enable = true;
    };
  };
}
