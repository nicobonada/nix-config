function icon_folders --description "generate icon_folders line for dunstrc"
    printf 'icon_folders = "'
    for i in /usr/share/icons/Numix/32/*
        printf $i/:
    end
    for i in /usr/share/icons/Numix/scalable/*
        printf $i/:
    end | sed 's/:$//'
    printf '"\n'
end
