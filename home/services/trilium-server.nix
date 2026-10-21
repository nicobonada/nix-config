{
  imports = [ ../modules/trilium-server.nix ];

  # Off while trilium-server 0.106.0's bundled node segfaults in ld.so.
  # The restart loop blocks home activation. Turn this back on once
  # that binary starts. Password stays in secrets/trilium.yaml.
  services.trilium-server = {
    enable = false;
    # 37841: desktop Electron already uses 37840 for MCP.
    port = 37841;
    sync.serverHost = "https://nico-notes.pikapod.net";
    bootstrap.enable = true;
  };
}
