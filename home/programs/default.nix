{ inputs, pkgs, lib, config, ... }:
{
  imports = [
    inputs.nix-index-database.homeModules.nix-index

    ./bashmount.nix
    ./kitty.nix
    ./mpv.nix
    ./nvim.nix
    ./obs.nix

    ./dank
    ./fish
    ./git
  ];

  programs = {
    delta.enable = true;
    delta.enableGitIntegration = lib.mkIf config.programs.git.enable true;

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
  };
}
