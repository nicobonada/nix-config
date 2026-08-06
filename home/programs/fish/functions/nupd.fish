function nupd --description 'update system and home'
    nh os switch --update ~/src/nix-config
    if test (nmcli networking connectivity check) = full
        nh home switch ~/src/nix-config
    end
end
