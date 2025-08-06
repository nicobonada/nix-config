{ inputs, lib, config, pkgs, ... }:
{
  imports = [ inputs.stylix.homeModules.stylix ];

  stylix.enable = true;
  stylix.base16Scheme = "${pkgs.base16-schemes}/share/themes/catppuccin-mocha.yaml";

  # stylix.fonts = {
  #   sansSerif = {
  #     name = "Comic Neue";
  #     package = pkgs.comic-neue;
  #   };
  #   monospace = {
  #     name = "Comic Code Ligatures";
  #   };
  # };
}
