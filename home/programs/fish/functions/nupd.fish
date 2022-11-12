function nupd --description 'update system and home'
    nix flake update ~/nix-config
    sudo nixos-rebuild switch --flake ~/nix-config
    home-manager switch --flake ~/nix-config
end
