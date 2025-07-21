{ pkgs, lib, ... }:
{
  programs.rofi = {
    enable = true;
    package = pkgs.rofi-wayland;
    theme = ./themes/catppuccin-macchiato.rasi;
    font = "Inter Regular 12";
    extraConfig = {
      modi = "window,run,ssh,drun";
      show-icons = true;
      icon-theme = "Papirus-Dark";
      run-command = "${lib.getExe pkgs.app2unit} -- {cmd}";
    };
  };
}
