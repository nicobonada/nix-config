{ lib, ... }:
{
  wayland.windowManager.hyprland = {
    enable = true;
    systemd.enable = false;
    extraConfig = builtins.readFile ./hyprland.conf;
  };

  programs.hyprlock = {
    enable = true;
    extraConfig = builtins.readFile ./hyprlock.conf;
  };

  services.hypridle.enable = true;
  xdg.configFile."hypr/hypridle.conf".source = ./hypridle.conf;
  systemd.user.services.hypridle.Unit.After = lib.mkForce "graphical-session.target";

  xdg.configFile."uwsm/env".source = ./uwsm-env;
}
