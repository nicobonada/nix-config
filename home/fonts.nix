{ pkgs, ... }:
{
  fonts.fontconfig.enable = true;

  home.packages = with pkgs; [
    noto-fonts
    comic-neue
    font-awesome_5
    inter
    nerd-fonts.fira-code
    noto-fonts-color-emoji
  ];
}
