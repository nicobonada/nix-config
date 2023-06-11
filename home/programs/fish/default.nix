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
      alias aunpack 'aunpack -e'
      alias bm      'bashmount'
      alias df      'duf -hide special'
      alias diff    'diff --color=auto'
      alias dmesg   'dmesg --ctime'
      alias dvid    'yt-dlp (xsel -ob)'
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

      abbr --add --global ns     'nix search nixpkgs'
      abbr --add --global jc     journalctl
      abbr --add --global mz     'mpv --autofit-smaller=50%'
      abbr --add --global sc     'sudo systemctl'
      abbr --add --global scu    'systemctl --user'
      abbr --add --global broken 'sudo env NIXPKGS_ALLOW_BROKEN=1 nixos-rebuild switch'

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
