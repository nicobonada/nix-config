{ config, pkgs, lib, ... }:
{
  programs.jujutsu = {
    enable = true;
    settings = {
      user = {
        name = config.programs.git.settings.user.name;
        email = config.programs.git.settings.user.email;
      };

      ui = {
        default-command = "status";
        graph.style = "curved";
        pager = "${lib.getExe pkgs.delta}";
        diff-formatter = ":git";  # delta needs this
      };
    };
  };

  home.packages = with pkgs; [
    jj-fzf
    jjui
    lazyjj
  ];
}
