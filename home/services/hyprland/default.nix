{ ... }:
{
  wayland.windowManager.hyprland = {
    enable = true;
    extraConfig = builtins.readFile ./hyprland.conf;
  };

  programs.hyprlock = {
    enable = true;
    extraConfig = builtins.readFile ./hyprlock.conf;
  };

  services.hypridle.enable = true;
  xdg.configFile."hypr/hypridle.conf".source = ./hypridle.conf;
}
