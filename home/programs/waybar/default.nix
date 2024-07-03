{ ... }:
{
  programs.waybar = {
    enable = true;
    systemd.enable = true;
    style = ./translucent.css;
  };

  xdg.configFile."waybar/config.jsonc".source = ./config.jsonc;
}
