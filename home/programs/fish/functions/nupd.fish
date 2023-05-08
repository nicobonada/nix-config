function nupd --description 'update system and home'
    nix flake update ~/nix-config
    if test $HOSTNAME != 'ost-nobonada'
        sudo nixos-rebuild switch --flake ~/nix-config
    end
    home-manager switch --flake ~/nix-config
end
