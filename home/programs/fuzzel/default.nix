{ lib, pkgs, ...}:
{
  programs.fuzzel = {
    enable = true;

    settings = {
      main = {
        dpi-aware = true;
        font = "Inter Regular 12";
        icon-theme = "Papirus-Dark";
        terminal = "${lib.getExe pkgs.kitty} -e";
        launch-prefix = "uwsm app --";
      };

      border.width = 3;

      colors = {
        # catpuccin machiatto blue
        background      = "24273add";
        text            = "cad3f5ff";
        prompt          = "b8c0e0ff";
        placeholder     = "8087a2ff";
        input           = "cad3f5ff";
        match           = "8aadf4ff";
        selection       = "5b6078ff";
        selection-text  = "cad3f5ff";
        selection-match = "8aadf4ff";
        counter         = "8087a2ff";
        border          = "8aadf4ff";
      };
    };
  };
}
