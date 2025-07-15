{ lib, pkgs, ...}:
{
  programs.fuzzel = {
    enable = true;

    settings = {
      main = {
        dpi-aware = "no";
        font = "Inter Regular:size=14";
        icon-theme = "Papirus-Dark";
        terminal = "${lib.getExe pkgs.kitty} -e";
        launch-prefix = "${lib.getExe pkgs.app2unit} --fuzzel-compat -- ";
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
