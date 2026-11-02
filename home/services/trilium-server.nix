{ pkgs, ... }:
let
  # autoPatchelf + patchelf 0.19.2 SIGSEGVs bundled node in ld.so
  # (NixOS/nixpkgs#579143). Put 0.15.2 first on PATH until that is
  # fixed. Same pin as gnat-bootstrap / androidenv.
  patchelf_0_15_2 = pkgs.patchelf.overrideAttrs (
    finalAttrs: _prev: {
      version = "0.15.2";
      src = pkgs.fetchurl {
        url = "https://github.com/NixOS/patchelf/releases/download/${finalAttrs.version}/patchelf-${finalAttrs.version}.tar.bz2";
        hash = "sha256-F3RfVkFZyOIo/EEtplogSLhGxLa0Igt3y/IkFuAvLXw=";
      };
    }
  );
in
{
  imports = [ ../modules/trilium-server.nix ];

  services.trilium-server = {
    enable = true;
    package = pkgs.trilium-server.overrideAttrs (old: {
      nativeBuildInputs = [ patchelf_0_15_2 ] ++ (old.nativeBuildInputs or [ ]);
    });
    # 37841: desktop Electron already uses 37840 for MCP.
    port = 37841;
    sync.serverHost = "https://nico-notes.pikapod.net";
    bootstrap.enable = true;
  };
}
