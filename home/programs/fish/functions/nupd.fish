function nupd --description 'update system and home'
    nix flake update ~/nix-config
    if test (hostname) != 'ost-nobonada'
        sudo nixos-rebuild switch --flake ~/nix-config
    end
    if test (nmcli networking connectivity check) = 'full'
        home-manager switch --flake ~/nix-config
    end
end
