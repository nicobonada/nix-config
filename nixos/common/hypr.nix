{ pkgs , ...}:
{
  services.greetd = {
    enable = true;
    settings = {
      default_session.command = /*bash*/''
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
      lxqt.lxqt-policykit
      nwg-displays
      qt5.qtwayland
      qt6.qtwayland
      satty
      slurp # needed for wl-screenrec
      wayland-pipewire-idle-inhibit
      wl-clipboard-rs
      wl-screenrec
      wtype
    ];
  };
}
