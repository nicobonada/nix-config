{
  programs.bat = {
    enable = true;
    config = { theme = "Enki-Tokyo-Night"; }; # Run 'bat cache --build' after changing this
    themes = {
      Enki-Tokyo-Night = { src = ./themes/Enki-Tokyo-Night.tmTheme; };
    };
  };
}
