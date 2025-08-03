{ pkgs, ... }:
{
  fonts.fontconfig.enable = true;

  home.packages = with pkgs; [
    cascadia-code
    comic-neue
    font-awesome_5
    inter
    nerd-fonts.fira-code
    nerd-fonts.jetbrains-mono
    noto-fonts
    noto-fonts-color-emoji
  ];
}
