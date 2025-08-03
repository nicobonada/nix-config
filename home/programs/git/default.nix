{ pkgs, ... }:
{
  imports = [
    ./jujutsu.nix
  ];

  programs.git = {
    enable = true;

    package = pkgs.gitFull;

    userName = "Nicolás Bonada";
    userEmail = "nico.bonada@gmail.com";

    aliases.st = "status";

    delta.enable = true;

    extraConfig = {
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
