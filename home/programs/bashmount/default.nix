{ ... }:
{
  programs.bashmount = {
      enable = true;
      extraConfig = builtins.readFile ./config;
  };
}
