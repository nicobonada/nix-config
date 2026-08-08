function __prompt_path_has --argument-names name --description 'True if name exists in $PWD or a parent'
    for d in (__fish_parent_directories $PWD)
        test -e $d/$name && return 0
    end
    return 1
end
