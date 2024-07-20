{
  imports = [
    ./bashmount
    ./bat
    ./fish
    ./git
    ./kitty
    ./mpv
    ./nvim
    ./rofi
    ./waybar
  ];

  programs = {
    man.generateCaches = true;

    btop.enable = true;
    btop.settings = { color_theme = "tokyo-storm"; };

    fzf.enable = true;
    zoxide.enable = true;
    ranger.enable = true;
    fastfetch.enable = true;
    yt-dlp.enable = true;

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
