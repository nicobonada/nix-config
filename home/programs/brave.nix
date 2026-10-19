{ pkgs, lib, ... }:
let
  custom = import ../../pkgs { inherit pkgs; };
  braveDesktop =
    {
      name,
      class,
      newWindow ? false,
      noDisplay ? false,
    }:
    {
      inherit name noDisplay;
      genericName = "Web Browser";
      exec = "${class}${lib.optionalString newWindow " --new-window"} %U";
      icon = "brave-browser";
      terminal = false;
      categories = [
        "Network"
        "WebBrowser"
      ];
      mimeType = [
        "text/html"
        "x-scheme-handler/http"
        "x-scheme-handler/https"
      ];
      startupNotify = true;
      settings.StartupWMClass = class;
    };
in
{
  # Default browser: work Brave for xdg-open / handlers.
  # force: pre-existing ~/.config/mimeapps.list from manual/desktop use.
  # brave-work-open is the handler. --new-window maps a toplevel on the
  # focused workspace. A plain launch would tab into a window elsewhere.
  xdg.configFile."mimeapps.list".force = true;
  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "text/html" = "brave-work-open.desktop";
      "x-scheme-handler/http" = "brave-work-open.desktop";
      "x-scheme-handler/https" = "brave-work-open.desktop";
      "x-scheme-handler/about" = "brave-work-open.desktop";
      "x-scheme-handler/unknown" = "brave-work-open.desktop";
    };
  };

  xdg.desktopEntries = {
    brave-work = braveDesktop {
      name = "Brave (work)";
      class = "brave-work";
    };
    brave-work-open = braveDesktop {
      name = "Brave (work)";
      class = "brave-work";
      newWindow = true;
      noDisplay = true;
    };
    brave-personal = braveDesktop {
      name = "Brave (personal)";
      class = "brave-personal";
    };
    brave-scratch = braveDesktop {
      name = "Brave (scratch)";
      class = "brave-scratch";
    };
  };

  # Brave profiles (see pkgs/brave.nix). Work is the default browser.
  home.packages = [
    custom.brave-work
    custom.brave-personal
    custom.brave-scratch
  ];
}
