{ pkgs, ... }:
{
  programs.bashmount = {
      enable = true;

      extraConfig = /*bash*/''
        filemanager() {
            ( cd "$1" && ${pkgs.fish}/bin/fish )
        }
      '';
  };
}
