{

  programs.fish = {
    enable = true;
    shellInit = ''
      set BROWSER "vivaldi"
      set -gx EDITOR nvim
    '';
    interactiveShellInit = ''
      set -gx LS_COLORS (vivid generate iceberg-dark)

      alias VV      'nvim ~/.config/nixpkgs/configs/nviminit.lua'
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
      alias ndiff   'nix profile diff-closures --profile /nix/var/nix/profiles/system'
      alias hdiff   'nix profile diff-closures --profile /nix/var/nix/profiles/per-user/nico/profile'

      set -gx LESS "-iRSX"

      function ls --description "List directory contents"
          command ls --group-directories-first --classify --human-readable --time-style=long-iso --color=auto $argv
      end

      if test $hostname = "navi"
        abbr --add --global mz     'mpv --autofit-smaller=75%'
      else
        abbr --add --global mz     'mpv --autofit-smaller=50%'
      end
      abbr --add --global gmpv   'gamescope -f -m 1.5 -- mpv'
      abbr --add --global jc     journalctl
      abbr --add --global sc     'sudo systemctl'
      abbr --add --global scu    'systemctl --user'

      fish_add_path ~/bin

      source ~/.config/fish/tokyonight_storm.fish

      if test $TERM = "xterm-kitty"
          kitty + complete setup fish | source
      end
    '';
  };

  xdg.configFile."fish/tokyonight_storm.fish".source = ./tokyonight_storm.fish;
  xdg.configFile."fish/functions".source = ./functions;
}
