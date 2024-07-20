{ pkgs, ... }:
{
  fonts.fontconfig.enable = true;

  home.packages = with pkgs; [
    noto-fonts
    comic-neue
    font-awesome_5
    inter
    (nerdfonts.override { fonts = [ "FiraCode" ]; })
    noto-fonts-emoji
  ];
}
