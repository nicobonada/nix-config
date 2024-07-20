{ pkgs, ... }:
{
  imports = [
    ./bashmount
    ./bat
    ./fish
    ./git
    ./kitty
    ./mpv
    ./nvim
    ./rofi
    ./waybar
  ];

  programs = {
    man.generateCaches = true;

    btop.enable = true;
    btop.settings = { color_theme = "tokyo-storm"; };

    fzf.enable = true;
    zoxide.enable = true;
    ranger.enable = true;
    fastfetch.enable = true;
    yt-dlp.enable = true;

    hyprcursor-phinger.enable = true;
  };

  # needed for gtk apps as they don't support hardware cursors
  home.packages = [ pkgs.phinger-cursors ];
}
