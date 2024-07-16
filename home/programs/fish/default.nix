{

  programs.fish = {
    enable = true;
    shellInit = ''
      set BROWSER "vivaldi"
      set -gx EDITOR nvim
    '';
    interactiveShellInit = builtins.readFile ./interactive.fish;
  };

  xdg.configFile = {
    "fish/tokyonight_storm.fish".source = ./tokyonight_storm.fish;
    "fish/functions".source = ./functions;
    "vivid/themes/tokyonight-storm-vivid-nobold.yml".source = ./tokyonight-storm-vivid-nobold.yml;
  };
}
