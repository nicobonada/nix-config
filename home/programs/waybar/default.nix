{ ... }:
{
  programs.waybar.enable = true;

  xdg.configFile."waybar".source = ./settings;
}
