alias aria    'aria2c -j 1 -s 1 -c'
alias aunpack 'patool extract'
alias bm      'bashmount'
alias df      'duf -hide special'
alias diff    'diff --color=auto'
alias dmesg   'dmesg --ctime'
alias dvid    'yt-dlp (wl-paste)'
alias locate  'locate -i'
alias map     'map 60x30n180dn'
alias psg     'procs'
alias qmv     'qmv --options=spaces'
alias rescan  'nmcli dev wifi rescan'
alias zzz     'systemctl suspend'

# nix related aliases
alias HH      'nvim ~/nix-config/home/nico.nix'
alias gens    'sudo nix-env -p /nix/var/nix/profiles/system --list-generations'

set -gx LESS "-iRSX"

function ls --description "List directory contents"
    command ls --group-directories-first --classify --human-readable --time-style=long-iso --color=auto $argv
end

abbr --add --global mf     'mpv --fullscreen --video-unscaled=downscale-big'
abbr --add --global jc     journalctl
abbr --add --global sc     'sudo systemctl'
abbr --add --global scu    'systemctl --user'
abbr --add --global st     'sudo systemctl-tui'
abbr --add --global stu    'systemctl-tui -s user'

source ~/.config/fish/tokyonight_storm.fish
