{
  description = "nix config";

  inputs = {
    # Nixpkgs
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    stable.url =  "github:nixos/nixpkgs/nixos-24.11";

    # Home manager
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    # hardware.url = "github:nixos/nixos-hardware";
    hyprcursor-phinger.url = "github:jappie3/hyprcursor-phinger";
  };

  outputs = { nixpkgs, home-manager, stable, ... }@inputs: {
    nixosConfigurations = {
      navi = nixpkgs.lib.nixosSystem {
        specialArgs = { inherit inputs; }; # Pass flake inputs to our config
        modules = [ ./nixos/navi/configuration.nix ];
      };

      oakhill = nixpkgs.lib.nixosSystem {
        specialArgs = { inherit inputs; }; # Pass flake inputs to our config
        modules = [ ./nixos/oakhill/configuration.nix ];
      };
    };

    homeConfigurations = {
      nico = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.x86_64-linux;
        extraSpecialArgs = { inherit inputs; pkgs-stable = stable.legacyPackages.x86_64-linux; }; # Pass flake inputs to our config
        modules = [ ./home/nico.nix ];
      };
    };
  };
}
