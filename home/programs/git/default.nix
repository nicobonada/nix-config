{ lib, pkgs, config, ... }:
{
  imports = [
    ./jujutsu.nix
  ];

  programs.git = {
    enable = true;

    package = pkgs.gitFull;

    signing.format = null;

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

  programs.delta.enable = true;
  programs.delta.enableGitIntegration = lib.mkIf config.programs.git.enable true;

  home.packages = with pkgs; [
    lazygit
    gh
  ];
}
