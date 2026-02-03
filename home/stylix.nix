{ inputs, lib, config, pkgs, ... }:
{
  imports = [ inputs.stylix.homeModules.stylix ];

  stylix = {
    enable = true;
    autoEnable = false;
    base16Scheme = "${pkgs.base16-schemes}/share/themes/kanagawa.yaml";
    polarity = "dark";

    fonts = {
      sansSerif.name = "Comic Neue";
      monospace.name = "Comic Code Ligatures";

      sizes = {
        applications = 12;
        desktop = 12;
      };
    };

    # icons = {
    #   enable = true;
    #   dark = "Papirus-Dark";
    # };
    #
    targets = {
      fish.enable = true;
      vivid.enable = true;
      yazi.enable = true;
      jjui.enable = true;
    };
  };
}
