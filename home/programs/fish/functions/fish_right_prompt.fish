function fish_right_prompt --description 'Path and active nix-shell'
    set_color white
    echo -n (prompt_pwd)
    set_color normal

    # Actual shell env (not path markers) — can grow later.
    if set -q IN_NIX_SHELL && test -n "$IN_NIX_SHELL"
        set_color yellow
        echo -n " nix:$IN_NIX_SHELL"
        set_color normal
    end
end
