{ pkgs , lib, config, ...}:
{
  security.pam.services.hyprlock = {};

  programs.hyprland = {
    enable = true;
    withUWSM = true;
  };

  environment = {
    # hint electron apps to use wayland:
    sessionVariables.NIXOS_OZONE_WL = "1";
    # For packages that dont yet support the above
    sessionVariables.ELECTRON_OZONE_PLATFORM_HINT = "auto";

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
      wayscriber
      wl-clipboard-rs
      wl-screenrec
      wtype
    ];
  };
}
