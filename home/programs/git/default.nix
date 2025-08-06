{ pkgs, ... }:
{
  imports = [
    ./jujutsu.nix
  ];

  programs.git = {
    enable = true;

    package = pkgs.gitFull;

    settings = {
      user.name = "Nicolás Bonada";
      user.email = "nico.bonada@gmail.com";
      alias.st = "status";
      diff.tool = "kdiff3";
      merge.tool = "kdiff3";
      init.defaultBranch = "main";
      pull.rebase = "false";
    };
  };

  home.packages = with pkgs; [
    lazygit
  ];
}
