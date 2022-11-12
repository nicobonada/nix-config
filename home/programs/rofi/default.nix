{
  programs.rofi = {
    enable = true;
    theme = ./themes/catppuccin-macchiato.rasi;
    font = "Inter Regular 12";
    extraConfig = {
      modi = "window,run,ssh,drun";
      show-icons = true;
      icon-theme = "kora";
      dpi = 0;
    };
  };
}
