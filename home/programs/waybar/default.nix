{ ... }:
{
  programs.waybar.enable = true;

  xdg.configFile."waybar/config.jsonc".source = ./settings/config.jsonc;
  xdg.configFile."waybar/oakhill.jsonc".source = ./settings/oakhill.jsonc;
  xdg.configFile."waybar/seyruun.jsonc".source = ./settings/seyruun.jsonc;
}
