{ inputs, pkgs , ...}:
{
  nix.settings = {
    substituters = [ "https://hyprland.cachix.org" ];
    trusted-public-keys = [
      "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
    ];
  };

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
  programs.hyprland.portalPackage = inputs.xdph.packages.${pkgs.system}.xdg-desktop-portal-hyprland.override {
    inherit (pkgs) mesa;
  };
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
      lxqt.lxqt-policykit
    ];
  };
}
