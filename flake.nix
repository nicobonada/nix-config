{
  description = "nix config";

  inputs = {
    # Nixpkgs
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    # Determinate Nix (stay on DetSys; not Lix/CppNix).
    determinate.url = "https://flakehub.com/f/DeterminateSystems/determinate/*";

    # Home manager
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # amd microcode
    ucodenix.url = "github:e-tho/ucodenix";

    # neovim
    nvf = {
      url = "github:NotAShelf/nvf";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    auto-cpufreq = {
      url = "github:AdnanHodzic/auto-cpufreq";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    stylix = {
      url = "github:nix-community/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Own nixpkgs pin so packages hit noctalia.cachix.org.
    # home-manager's programs.noctalia defaults to pkgs.noctalia; gui sets
    # package to this flake's output.
    noctalia.url = "github:noctalia-dev/noctalia";

    noctalia-greeter = {
      url = "github:noctalia-dev/noctalia-greeter";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Grok Build (numtide). Wrapper + agent-apps live in pkgs/grok.
    # Do not follow nixpkgs: their grok binary uses their toolchain.
    llm-agents.url = "github:numtide/llm-agents.nix";

    # Status dashboard for flakes under ~/src (public; read-only TUI)
    flake-status = {
      url = "github:nicobonada/flake-status";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # oakhill disk layout (nixos/oakhill/disks.nix). Description + mounts only —
    # do not run the disko destroy/format CLI against the live pool.
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    disko-zfs = {
      url = "github:numtide/disko-zfs";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.disko.follows = "disko";
    };
  };

  outputs =
    { nixpkgs, home-manager, ... }@inputs:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };
    in
    {
      nixosConfigurations = {
        oakhill = nixpkgs.lib.nixosSystem {
          specialArgs = { inherit inputs; }; # Pass flake inputs to our config
          modules = [ ./nixos/oakhill/configuration.nix ];
        };

        seyruun = nixpkgs.lib.nixosSystem {
          specialArgs = { inherit inputs; }; # Pass flake inputs to our config
          modules = [ ./nixos/seyruun/configuration.nix ];
        };
      };

      homeConfigurations = {
        nico = home-manager.lib.homeManagerConfiguration {
          # Instantiate pkgs with allowUnfree so home.nix’s unfree packages work —
          # legacyPackages ignores module nixpkgs.config.
          inherit pkgs;
          extraSpecialArgs = {
            inherit inputs;
            grokPkg = pkgs.callPackage ./pkgs/grok {
              grok-unwrapped = inputs.llm-agents.packages.${system}.grok;
            };
          };
          modules = [ ./home/nico.nix ];
        };
      };

      # Mutating beets work: pauses Syncthing music + beets-state until the shell exits.
      #   nix develop .#beets
      #   beet import …
      #   exit
      # Requires home-manager beets-syncthing-pause/resume on PATH (or nix shell them).
      devShells.${system}.beets = pkgs.mkShell {
        name = "beets";
        packages = with pkgs; [
          beets
          sqlite
          syncthing
        ];
        shellHook = ''
          pause_bin="$(command -v beets-syncthing-pause || true)"
          resume_bin="$(command -v beets-syncthing-resume || true)"
          if [[ -z $pause_bin || -z $resume_bin ]]; then
            echo "beets shell: beets-syncthing-pause/resume not on PATH" >&2
            echo "  → home-manager switch first (or: nix shell path:~/src/nix-config …)" >&2
          else
            "$pause_bin" || echo "beets shell: pause failed (is syncthing running?)" >&2
            trap '"$resume_bin" || true' EXIT
          fi
          echo "beets shell: Syncthing music + beets-state paused until exit"
          echo "  library: ~/.local/share/beets-state/library.db"
        '';
      };
    };
}
