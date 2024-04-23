function nupd --description 'update system and home'
    nh os switch --update ~/nix-config
    if test (nmcli networking connectivity check) = 'full'
        nh home switch ~/nix-config
    end
end
