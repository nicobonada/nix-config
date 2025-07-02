{ pkgs, ... }:
{
  hardware.steam-hardware.enable = true;
  programs.steam.enable = true;

  programs.gamemode.enable = true;
  users.extraUsers.nico.extraGroups = [ "gamemode" ];

  environment.systemPackages = with pkgs; [
    dualsensectl
    mangohud
    prismlauncher
    protonup-qt
  ];
}

