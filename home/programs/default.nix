{ inputs, pkgs, lib, config, ... }:
{
  imports = [
    inputs.hyprcursor-phinger.homeManagerModules.hyprcursor-phinger
    inputs.nix-index-database.homeModules.nix-index

    ./bashmount
    ./fish
    ./git
    ./kitty
    ./mpv
    ./nvim
    ./obs
    # ./waybar

    ./dank
  ];

  programs = {
    delta.enable = true;
    delta.enableGitIntegration = lib.mkIf config.programs.git.enable true;

    vicinae.enable = true;
    vicinae.systemd.enable = true;

    bat.enable = true;
    btop.enable = true;
    discord.enable = true;
    fastfetch.enable = true;
    nix-index.enable = true;
    television.enable = true;
    vivid.enable = true;
    yazi.enable = true;
    yt-dlp.enable = true;
    zoxide.enable = true;

    hyprcursor-phinger.enable = true;
  };
}
