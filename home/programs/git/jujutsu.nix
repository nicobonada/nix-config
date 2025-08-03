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

      templates = {
        draft_commit_description = ''
          concat(
            coalesce(description, default_commit_description, "\n"),
            surround(
              "\nJJ: This commit contains the following changes:\n", "",
              indent("JJ:     ", diff.stat(72)),
            ),
            "\nJJ: ignore-rest\n",
            diff.git(),
          )
        '';
      };
    };
  };

  home.packages = with pkgs; [
    jj-fzf
    jjui
    lazyjj
  ];
}
