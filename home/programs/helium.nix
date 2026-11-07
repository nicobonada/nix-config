{
  pkgs,
  lib,
  inputs,
  ...
}:
let
  heliumPkg = inputs.helium.packages.${pkgs.stdenv.hostPlatform.system}.helium;
  profiles = pkgs.callPackage ../../pkgs/helium.nix { helium = heliumPkg; };
  heliumDesktop =
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
      icon = "${heliumPkg}/share/icons/hicolor/256x256/apps/helium.png";
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
  # Default browser: work Helium for xdg-open / handlers.
  # force: pre-existing ~/.config/mimeapps.list from manual/desktop use.
  # helium-work-open is the handler. --new-window maps a toplevel on the
  # focused workspace. A plain launch would tab into a window elsewhere.
  xdg.configFile."mimeapps.list".force = true;
  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "text/html" = "helium-work-open.desktop";
      "x-scheme-handler/http" = "helium-work-open.desktop";
      "x-scheme-handler/https" = "helium-work-open.desktop";
      "x-scheme-handler/about" = "helium-work-open.desktop";
      "x-scheme-handler/unknown" = "helium-work-open.desktop";
    };
  };

  xdg.desktopEntries = {
    helium-work = heliumDesktop {
      name = "Helium (work)";
      class = "helium-work";
    };
    helium-work-open = heliumDesktop {
      name = "Helium (work)";
      class = "helium-work";
      newWindow = true;
      noDisplay = true;
    };
    helium-personal = heliumDesktop {
      name = "Helium (personal)";
      class = "helium-personal";
    };
    helium-scratch = heliumDesktop {
      name = "Helium (scratch)";
      class = "helium-scratch";
    };
  };

  # Helium profiles (see pkgs/helium.nix). Work is the default browser.
  home.packages = [
    profiles.helium-work
    profiles.helium-personal
    profiles.helium-scratch
  ];
}
