# Generated via dconf2nix: https://github.com/gvolpe/dconf2nix
{ lib, ... }:

with lib.hm.gvariant;

{
  dconf.settings = {
    "apps/seahorse/listing" = {
      keyrings-selected = [ "secret-service:///org/freedesktop/secrets/collection/login" ];
    };

    "apps/seahorse/windows/key-manager" = {
      height = 849;
      width = 691;
    };

    "ca/desrt/dconf-editor" = {
      saved-pathbar-path = "/org/gtk/settings/file-chooser/";
      saved-view = "/org/gtk/settings/file-chooser/";
      show-warning = false;
      window-height = 500;
      window-is-maximized = true;
      window-width = 540;
    };

    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
      cursor-size = 24;
      cursor-theme = "phinger-cursors-light";
      font-antialiasing = "grayscale";
      font-hinting = "slight";
      font-name = "Inter Light 10";
      font-rgba-order = "rgb";
      gtk-theme = "Adwaita";
      icon-theme = "Papirus-Dark";
      text-scaling-factor = 1.0;
      toolbar-icons-size = "large";
      toolbar-style = "both-horiz";
    };

    "org/gnome/desktop/privacy" = {
      remember-recent-files = false;
    };

    "org/gnome/desktop/sound" = {
      event-sounds = true;
      input-feedback-sounds = false;
    };

    "org/gtk/settings/file-chooser" = {
      date-format = "regular";
      location-mode = "path-bar";
      show-hidden = false;
      show-size-column = true;
      show-type-column = true;
      sidebar-width = 171;
      sort-column = "name";
      sort-directories-first = false;
      sort-order = "ascending";
      startup-mode = "cwd";
      type-format = "category";
      window-position = mkTuple [ 0 0 ];
      window-size = mkTuple [ 748 464 ];
    };

  };
}
