{ lib, pkgs, ... }:
{
  programs.kitty = {
    enable = true;

    settings = {
      shell = "${lib.getExe pkgs.fish}";
      enable_audio_bell = "no";
      tab_bar_style = "powerline";
      cursor_blink_interval = 0;

      # Close the window when the child process (usually the shell) exits
      close_on_child_death = "yes";

      scrollback_pager_history_size = 20;  # size is in MB
    };

    themeFile = "everforest_dark_hard";
    font.name = "Comic Code Ligatures";
    font.size = 12;

    # this is to stop other random fonts from taking over the symbols
    extraConfig = ''
      symbol_map U+E5FA-U+E6B7 Symbols Nerd Font
      symbol_map U+E700-U+E8EF Symbols Nerd Font
      symbol_map U+ED00-U+F2FF Symbols Nerd Font
      symbol_map U+E200-U+E2A9 Symbols Nerd Font
      symbol_map U+F0001-U+F1AF0 Symbols Nerd Font
      symbol_map U+E300-U+E3E3 Symbols Nerd Font
      symbol_map U+F400-U+F533,U+2665,U+26A1 Symbols Nerd Font
      symbol_map U+E0A0-U+E0A2,U+E0B0-U+E0B3 Symbols Nerd Font
      symbol_map U+E0A3,U+E0B4-U+E0C8,U+E0CA,U+E0CC-U+E0D7 Symbols Nerd Font
      symbol_map U+23FB-U+23FE,U+2B58 Symbols Nerd Font
      symbol_map U+F300-U+F381 Symbols Nerd Font
      symbol_map U+E000-U+E00A Symbols Nerd Font
      symbol_map U+EA60-U+EC1E Symbols Nerd Font
      symbol_map U+276C-U+2771,U+2500-U+259F,U+EE00-U+EE0B Symbols Nerd Font
    '';
  };
}
