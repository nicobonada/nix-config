function nupd --description 'update system and home'
    cd ~/nix-config
    nix flake update
    sudo nixos-rebuild switch --flake .
    home-manager switch --flake .
end
