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
  xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-gtk ];

  environment = {
    # hint electron apps to use wayland:
    sessionVariables.NIXOS_OZONE_WL = "1";

    systemPackages = with pkgs; [
      grim
      hyprshot
      nwg-displays
      qt5.qtwayland
      qt6.qtwayland
      wayland-pipewire-idle-inhibit
      wl-clipboard-rs
      wtype
    ];
  };
}
