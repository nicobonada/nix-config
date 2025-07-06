{ pkgs, ... }:
{
  programs.jujutsu = {
    enable = true;
    settings = {
      user = {
        name = "Nicolás Bonada";
        email = "nico.bonada@gmail.com";
      };

      ui = {
        default-command = "status";
        graph.style = "curved";
      };
    };
  };
}
