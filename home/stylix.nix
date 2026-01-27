{ inputs, lib, config, pkgs, ... }:
{
  imports = [ inputs.stylix.homeModules.stylix ];

  stylix = {
    enable = true;
    base16Scheme = "${pkgs.base16-schemes}/share/themes/tokyo-night-dark.yaml";
    polarity = "dark";

    fonts = {
      sansSerif.name = "Comic Neue";
      monospace.name = "Comic Code Ligatures";

      sizes = {
        applications = 12;
        desktop = 12;
      };
    };

    icons = {
      enable = true;
      dark = "Papirus-Dark";
    };

    targets = {
      gnome.enable = false;
      gtk.enable = false;
      kde.enable = false;

      hyprland.enable = false;
      hyprlock.enable = false;

      # using the built-in theme support for these
      vicinae.enable = false;
      nvf.enable = false;
      kitty.enable = false;

      qt.enable = true;
    };
  };
}
