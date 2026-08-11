{
  description = "nix config";

  inputs = {
    # Nixpkgs
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    # Determinate Nix (stay on DetSys; not Lix/CppNix). Exact non-prerelease pin.
    # FlakeHub `*` / `3` can resolve to GitHub prereleases — do not float blindly.
    # New 3.x minors/patches: run scripts/update-determinate (rewrites pin + lock).
    determinate.url = "https://flakehub.com/f/DeterminateSystems/determinate/=3.21.9";

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

    noctalia.url = "github:noctalia-dev/noctalia";

    noctalia-greeter = {
      url = "github:noctalia-dev/noctalia-greeter";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Wrapped Grok binary + thin HM module (not config.toml). Same pin every host.
    # Private definition repo: nicobonada/grok (was grok-config).
    grok.url = "git+ssh://git@github.com/nicobonada/grok.git";

    # Status dashboard for flakes under ~/src (public; read-only TUI)
    flake-status.url = "github:nicobonada/flake-status";
  };

  outputs = { nixpkgs, home-manager, ... }@inputs: {
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
        pkgs = import nixpkgs {
          system = "x86_64-linux";
          config.allowUnfree = true;
        };
        extraSpecialArgs = { inherit inputs; }; # Pass flake inputs to our config
        modules = [ ./home/nico.nix ];
      };
    };
  };
}
