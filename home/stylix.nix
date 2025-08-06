{ inputs, lib, config, pkgs, ... }:
{
  imports = [ inputs.stylix.homeModules.stylix ];

  stylix = {
    enable = true;
    base16Scheme = "${pkgs.base16-schemes}/share/themes/tokyo-night-dark.yaml";

    fonts = {
      sansSerif.name = "Comic Neue";
      monospace.name = "Comic Code Ligatures";

      sizes = {
        applications = 12;
        desktop = 12;
      };
    };

    targets = {
      gnome.enable = false;
      kde.enable = false;
      hyprland.enable = false;
      hyprlock.enable = false;
      waybar.enable = false;
      vicinae.enable = false;

      nvf.enable = false;
    };
  };
}
