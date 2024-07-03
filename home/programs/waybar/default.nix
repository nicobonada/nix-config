{ ... }:
{
  programs.waybar = {
    enable = true;
    style = ./translucent.css;
  };

  xdg.configFile."waybar/config.jsonc".source = ./config.jsonc;
}
