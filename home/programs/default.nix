{ pkgs, ... }:
{
  imports = [
    ./bat
    ./git
    ./kitty
    ./mpv
    ./nvim
    ./rofi
  ];

  programs.fish.enable = true;
  xdg.configFile."fish/config.fish".source = ./fish/config.fish;
  xdg.configFile."fish/tokyonight_storm.fish".source = ./fish/tokyonight_storm.fish;
  xdg.configFile."fish/functions".source = ./fish/functions;

  programs.bashmount = {
    enable = true;
    extraConfig = ''
      filemanager() {
          ( cd "$1" && fish )
      }
    '';
  };

  programs.man.generateCaches = true;

  programs.yt-dlp.enable = true;

  programs.mangohud.enable = true;
  programs.mangohud.settings = { fps_limit = 60; };

  programs.btop.enable = true;
  programs.btop.settings = { color_theme = "tokyo-storm"; };

  programs.ncmpcpp = {
    enable = true;
    settings = {
      progressbar_look = "->-";
      user_interface = "alternative";
      space_add_mode = "always_add";
      external_editor = "nvim";
    };
  };

}
