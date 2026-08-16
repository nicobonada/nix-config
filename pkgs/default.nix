# Custom packages for this flake (not nixpkgs).
# Modules: `let custom = import ../../pkgs { inherit pkgs; }; in …`
{ pkgs }:
let
  call = pkgs.callPackage;
in
rec {
  nix-pkgs-browse = call ./nix-pkgs-browse { };
  satty-last-screenshot = call ./satty-last-screenshot { };
  brave-with-cdp = call ./brave-with-cdp { };
  brave-docked = call ./brave-docked { };
  path-mirror = call ./path-mirror { };

  # Until nixpkgs yaak ≥ 2026.5.0 (PR 548416).
  yaak = call ./yaak { };

  beets-syncthing-pause = call ./beets-syncthing/pause.nix { };
  beets-syncthing-resume = call ./beets-syncthing/resume.nix { };
  beets-state-migrate = call ./beets-syncthing/state-migrate.nix { };

  work-ledger = call ./work-ledger { };
  work-ledger-scan = call ./work-ledger/scan.nix { };
  work-ledger-weekly = call ./work-ledger/weekly.nix { };

  # Factory: module supplies baseUrl / hub / passwordFile / …
  trilium-server-bootstrap = call ./trilium-server-bootstrap { };

  # Override gui if programs._1password-gui.package differs from default.
  onepassword-mcp-patched = call ./onepassword-mcp/patched.nix {
    gui = pkgs._1password-gui;
  };
  onepassword-mcp-for-grok = call ./onepassword-mcp/for-grok.nix {
    adapter = ../scripts/1password-mcp-adapter.py;
  };
}
