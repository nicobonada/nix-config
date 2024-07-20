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
}
