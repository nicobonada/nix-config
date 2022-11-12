{
  programs.kitty = {
    enable = true;
    font = {
      name = "FiraCode Nerd Font";
      size = 11;
    };
    settings = {
      shell = "fish";
      enable_audio_bell = "no";
      tab_bar_style = "powerline";
      cursor_blink_interval = 0;
    };
    extraConfig = builtins.readFile (./themes/tokyonight_storm.conf);
  };
}
