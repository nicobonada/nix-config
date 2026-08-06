{
  description = "nix config";

  inputs = {
    # Nixpkgs
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    # dnix
    determinate.url = "https://flakehub.com/f/DeterminateSystems/determinate/*";

    # Home manager
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    zen-browser = {
      url = "github:youwen5/zen-browser-flake";
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

    # Project-scoped Grok (not home-manager). Remote pin — same on every host.
    grok-config.url = "git+ssh://git@github.com/nicobonada/grok-config.git";
  };

  outputs = { nixpkgs, home-manager, grok-config, ... }@inputs: {
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
        pkgs = nixpkgs.legacyPackages.x86_64-linux;
        extraSpecialArgs = { inherit inputs; }; # Pass flake inputs to our config
        modules = [ ./home/nico.nix ];
      };
    };

    # Agent shell only — not on interactive PATH. See ~/src/grok-config README.
    devShells.x86_64-linux.default = grok-config.devShells.x86_64-linux.default;
  };
}
