{

  programs.fish = {
    enable = true;
    shellInit = ''
      set BROWSER "vivaldi"
      set -gx EDITOR nvim
    '';
    interactiveShellInit = builtins.readFile ./interactive.fish;
  };

  xdg.configFile."fish/tokyonight_storm.fish".source = ./tokyonight_storm.fish;
  xdg.configFile."fish/functions".source = ./functions;
}
