{ inputs, pkgs, ... }:
{
  imports = [
    inputs.hyprcursor-phinger.homeManagerModules.hyprcursor-phinger
    inputs.nix-index-database.homeModules.nix-index

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
    btop.enable = true;
    btop.settings = { color_theme = "tokyo-storm"; };

    yazi.enable = true;
    yazi.enableFishIntegration = false;

    fastfetch.enable = true;
    nix-index.enable = true;
    television.enable = true;
    yt-dlp.enable = true;
    zoxide.enable = true;

    hyprcursor-phinger.enable = true;
  };
}
