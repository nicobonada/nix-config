{ inputs, pkgs, lib, config, ... }:
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
    ./obs
    ./rofi
    ./waybar
  ];

  programs = {
    btop.enable = true;
    btop.settings = { color_theme = "tokyo-storm"; };

    delta.enable = true;
    delta.enableGitIntegration = lib.mkIf config.programs.git.enable true;

    yazi.enable = true;
    discord.enable = true;
    fastfetch.enable = true;
    nix-index.enable = true;
    television.enable = true;
    yt-dlp.enable = true;
    zoxide.enable = true;

    hyprcursor-phinger.enable = true;
  };
}
