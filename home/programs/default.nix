{ ... }:
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

  programs = {
    bashmount = {
      enable = true;
      extraConfig = ''
        filemanager() {
            ( cd "$1" && fish )
        }
      '';
    };

    man.generateCaches = true;

    yt-dlp.enable = true;

    btop.enable = true;
    btop.settings = { color_theme = "tokyo-storm"; };

    fzf.enable = true;
    fzf.enableFishIntegration = true;

    zoxide.enable = true;
    zoxide.enableFishIntegration = true;

    ranger.enable = true;

    fastfetch.enable = true;

    hyprcursor-phinger.enable = true;

    ncmpcpp = {
      enable = true;
      settings = {
        progressbar_look = "->-";
        user_interface = "alternative";
        space_add_mode = "always_add";
        external_editor = "nvim";
        browser_display_mode = "columns";
      };
    };
  };
}
