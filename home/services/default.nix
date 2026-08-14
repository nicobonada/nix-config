{ lib, ... }:
{
  imports = [
    ./beets-syncthing-scripts.nix
    ./mpd.nix
    ./path-mirror.nix
    ./syncthing.nix
    ./trilium-server.nix
    ./work-ledger.nix
  ];

  services = {
    kdeconnect.enable = true;
    easyeffects.enable = true;

    # Always-on Trilium for Grok MCP; separate dataDir from Electron desktop.
    # Always-on MCP/web; separate dataDir from Electron.
    # Password: sops secrets/trilium.yaml → trilium.document_password (not CHANGE_ME).
    trilium-server = {
      enable = true;
      # 37841: desktop Electron already uses 37840 for MCP.
      port = 37841;
      sync.serverHost = "https://nico-notes.pikapod.net";
      bootstrap.enable = true;
    };
  };
}
