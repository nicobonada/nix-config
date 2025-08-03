{ pkgs, ... }:
{
  fonts.fontconfig.enable = true;

  home.packages = with pkgs; [
    comic-neue
    font-awesome_5
    inter
    nerd-fonts.symbols-only
    noto-fonts
    noto-fonts-color-emoji
  ];
}
