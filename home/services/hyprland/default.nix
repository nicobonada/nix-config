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

  services.hyprpolkitagent.enable = true;

  services.hypridle.enable = true;
  xdg.configFile."hypr/hypridle.conf".source = ./hypridle.conf;

  xdg.configFile."uwsm/env".text = # sh
    ''
      export XCURSOR_SIZE=24
      export HYPRCURSOR_THEME="phinger-cursors-light"
      export HYPRCURSOR_SIZE=24
      export QT_QPA_PLATFORM="wayland"
      export QT_QPA_PLATFORMTHEME="qt6ct"
    '';
}
