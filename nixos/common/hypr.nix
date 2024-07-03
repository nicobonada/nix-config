{ pkgs , ...}:
{
  services.greetd = {
    enable = true;
    settings = {
      default_session.command = ''
        ${pkgs.greetd.tuigreet}/bin/tuigreet \
          --time \
          --asterisks \
          --user-menu \
          --cmd Hyprland
      '';
    };
  };

  security.pam.services.hyprlock = {};
  programs.hyprland.enable = true;
  services.hypridle.enable = true;

  # hint electron apps to use wayland:
  environment.sessionVariables.NIXOS_OZONE_WL = "1";

  environment.systemPackages = with pkgs; [
    dunst
    grim
    hypridle
    hyprlock
    hyprshot
    nwg-displays
    qt5.qtwayland
    qt6.qtwayland
    rofi-wayland
    waybar
    wayland-pipewire-idle-inhibit
    wl-clipboard-rs
  ];
}
