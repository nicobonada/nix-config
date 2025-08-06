{ lib, pkgs, ... }:
{
  programs.kitty = {
    enable = true;
    font = {
      package = pkgs.nerd-fonts.jetbrains-mono;
      name = "JetBrainsMono Nerd Font";
      size = 12;
    };
    settings = {
      shell = "${lib.getExe pkgs.fish}";
      enable_audio_bell = "no";
      tab_bar_style = "powerline";
      cursor_blink_interval = 0;

      # Close the window when the child process (usually the shell) exits
      close_on_child_death = "yes";

      scrollback_pager_history_size = 20;  # size is in MB
    };
    extraConfig = builtins.readFile ./themes/tokyonight_storm.conf;
  };
}
