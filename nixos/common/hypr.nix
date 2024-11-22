{ pkgs , lib, config, ...}:
{
  programs.uwsm = {
    enable = true;
    waylandCompositors.hyprland = {
      binPath = "/run/current-system/sw/bin/Hyprland";
      comment = "Hyprland session managed by uwsm";
      prettyName = "Hyprland";
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
      hyprpolkitagent
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
