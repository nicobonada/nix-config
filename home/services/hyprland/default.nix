{ pkgs, ... }:
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

  xdg.configFile."uwsm/env".text = /* sh */ ''
      export XCURSOR_SIZE=24
      export HYPRCURSOR_THEME="phinger-cursors-light"
      export HYPRCURSOR_SIZE=24
      export QT_QPA_PLATFORM="wayland"
      export QT_QPA_PLATFORMTHEME="qt6ct"
      export UWSM_APP_UNIT_TYPE="service"
      export APP2UNIT_SLICES='a=app-graphical.slice b=background-graphical.slice s=session-graphical.slice'
      export APP2UNIT_TYPE=service
      export XDG_CURRENT_DESKTOP="Hyprland"
    '';

  home.packages = with pkgs; [
    xorg.xrandr
    app2unit      # alternative to 'uwsm app' (faster)
  ];
}
