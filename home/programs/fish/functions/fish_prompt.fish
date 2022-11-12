function fish_prompt --description 'Write out the prompt'
    # echo -n (hostname)
    if test -n "$IN_NIX_SHELL"
        echo -n "<nix-shell> "
    end

    switch $USER
    case root
        set_color red
        echo -n '# '
    case '*'
        set_color green
        echo -n '$ '
    end

    set_color normal
end
