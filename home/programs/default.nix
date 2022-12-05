{ pkgs, ... }:
{
  imports = [
    ./bat
    ./fish
    ./git
    ./kitty
    ./mpv
    ./nvim
    ./rofi
  ];

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

  programs.fzf.enable = true;
  programs.fzf.enableFishIntegration = true;

  programs.zoxide.enable = true;
  programs.zoxide.enableFishIntegration = true;

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
