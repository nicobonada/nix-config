function fish_prompt --description 'Write out the prompt'
    # Place icon (first match): flake   home 󰋜  else tree 󰙅
    # Shell marker: user  (green)  root  (red)

    set -l icon
    set -l color

    if __prompt_path_has flake.nix
        set icon 
        set color cyan
    else if test "$PWD" = "$HOME" || string match -q -- "$HOME/*" "$PWD"
        set icon 󰋜
        set color blue
    else
        set icon 󰙅
        set color brblack
    end

    set_color $color
    echo -n $icon' '
    set_color normal

    switch $USER
        case root
            set_color red
            echo -n ' '
        case '*'
            set_color green
            echo -n ' '
    end
    set_color normal
end
