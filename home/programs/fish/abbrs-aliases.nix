{ lib, pkgs, ... }:
{
  programs.fish = {
    shellAbbrs = {
      mf  = "mpv --fullscreen --video-unscaled=downscale-big";
      jc  = "journalctl";
      sc  = "sudo systemctl";
      scu = "systemctl --user";
      st  = "sudo systemctl-tui";
      stu = "systemctl-tui -s user";
    };

    shellAliases = {
      aria    = "aria2c -j 1 -s 1 -c";
      aunpack = "patool extract";
      bm      = "bashmount";
      df      = "duf -hide special";
      diff    = "diff --color=auto";
      dmesg   = "dmesg --ctime";
      dvid    = "yt-dlp (wl-paste)";
      locate  = "locate -i";
      ls      = "ls --group-directories-first --classify --human-readable --time-style=long-iso --color=auto";
      map     = "map 60x30n180dn";
      psg     = "procs";
      rescan  = "nmcli dev wifi rescan";
      zzz     = "systemctl suspend";
      HH      = "nvim ~/nix-config/home/nico.nix";
    };
  };
}
