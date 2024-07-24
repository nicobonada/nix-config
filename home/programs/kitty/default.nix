{ pkgs, ... }:
{
  programs.kitty = {
    enable = true;
    font = {
      name = "FiraCode Nerd Font";
      size = 11;
    };
    settings = {
      shell = "${pkgs.fish}/bin/fish";
      enable_audio_bell = "no";
      tab_bar_style = "powerline";
      cursor_blink_interval = 0;

      # Close the window when the child process (usually the shell) exits
      close_on_child_death = "yes";
    };
    extraConfig = builtins.readFile ./themes/tokyonight_storm.conf;
  };
}
