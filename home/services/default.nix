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
    # Unattended hub join: set sync.serverHost + sops trilium/document_password
    # (not CHANGE_ME), then enable bootstrap.
    trilium-server = {
      enable = true;
      # sync.serverHost = "https://notes.example.com";
      # bootstrap.enable = true;
    };
  };
}
