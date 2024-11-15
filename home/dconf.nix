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
      saved-pathbar-path = "/org/blueman/plugins/";
      saved-view = "/org/blueman/plugins/";
      show-warning = false;
      window-height = 500;
      window-is-maximized = true;
      window-width = 540;
    };

    "org/blueman/general" = {
      window-properties = [ 691 903 0 0 ];
    };

    "org/blueman/network" = {
      nap-enable = false;
    };

    "org/blueman/plugins/powermanager" = {
      auto-power-on = false;
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

    "org/gnome/nm-applet/eap/057d7511-27f5-4be9-ab20-6d0ade48d9f4" = {
      ignore-ca-cert = false;
      ignore-phase2-ca-cert = false;
    };

    "org/gnome/nm-applet/eap/322fc470-0282-43d3-bb75-958331a0f27a" = {
      ignore-ca-cert = false;
      ignore-phase2-ca-cert = false;
    };

    "org/gnome/nm-applet/eap/fbca9679-39ce-425c-920f-436162f91cf8" = {
      ignore-ca-cert = false;
      ignore-phase2-ca-cert = false;
    };

    "org/gtk/gtk4/settings/color-chooser" = {
      custom-colors = [ (mkTuple [ 0.7843137383460999 0.14509804546833038 0.7215686440467834 1.0 ]) ];
      selected-color = mkTuple [ true 1.0 0.47058823704719543 0.0 1.0 ];
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
