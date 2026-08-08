function fish_prompt --description 'Write out the prompt'
    # One Nerd Font icon: first match wins (most specific → default).
    #   envrc 󰓦  flake   jj 󰋘  git   home 󰋜  default 󰐆

    set -l icon
    set -l color

    if __prompt_path_has .envrc
        set icon 󰓦
        set color yellow
    else if __prompt_path_has flake.nix
        set icon 
        set color cyan
    else if __prompt_path_has .jj
        set icon 󰋘
        set color magenta
    else if __prompt_path_has .git
        set icon 
        set color red
    else if test "$PWD" = "$HOME" || string match -q -- "$HOME/*" "$PWD"
        set icon 󰋜
        set color blue
    else
        set icon 󰐆
        set color brblack
    end

    set_color $color
    echo -n $icon' '
    set_color normal

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
