# Custom packages for this flake (not nixpkgs).
# Modules: `let custom = import ../../pkgs { inherit pkgs; }; in …`
{ pkgs }:
let
  call = pkgs.callPackage;
in
rec {
  nix-pkgs-browse = call ./nix-pkgs-browse { };
  # Cached nixpkgs solaar, plus the libnotify typelib its wrapper omits.
  solaar = call ./solaar.nix { };
  inherit (call ./brave.nix { }) brave-work brave-personal brave-scratch;
  path-mirror = call ./path-mirror { };

  # Steam compat tool: gamemoderun in front of the last protonup-rs Proton.
  proton-gamemode = call ./proton-gamemode.nix { };

  beets-syncthing-pause = call ./beets-syncthing/pause.nix { };
  beets-syncthing-resume = call ./beets-syncthing/resume.nix { };
  beets-state-migrate = call ./beets-syncthing/state-migrate.nix { };

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
