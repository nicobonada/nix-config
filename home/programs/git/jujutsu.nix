{ config, pkgs, ... }:
{
  programs.jujutsu = {
    enable = true;
    settings = {
      user = {
        name = config.programs.git.userName;
        email = config.programs.git.userEmail;
      };

      ui = {
        default-command = "status";
        graph.style = "curved";
      };
    };
  };

  home.packages = with pkgs; [
    jj-fzf
    lazyjj
  ];
}
