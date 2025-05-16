{ inputs, pkgs, ... }:
{
  imports = [
    inputs.hyprcursor-phinger.homeManagerModules.hyprcursor-phinger

    ./bashmount
    ./bat
    ./fish
    ./fuzzel
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

    yazi.enable = true;
    yazi.enableFishIntegration = false;

    fastfetch.enable = true;
    fzf.enable = true;
    television.enable = true;
    yt-dlp.enable = true;
    zoxide.enable = true;

    hyprcursor-phinger.enable = true;
  };

  # needed for gtk apps as they don't support hardware cursors
  home.packages = [ pkgs.phinger-cursors ];
}
