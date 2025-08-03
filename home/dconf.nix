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
      saved-pathbar-path = "/org/gnome/desktop/interface/font-name";
      saved-view = "/org/gnome/desktop/interface/font-name";
      show-warning = false;
      window-height = 500;
      window-is-maximized = true;
      window-width = 540;
    };

    "com/github/wwmm/easyeffects" = {
      use-dark-theme = true;
      window-fullscreen = false;
      window-height = 0;
      window-maximized = true;
      window-width = 0;
    };

    "com/github/wwmm/easyeffects/spectrum" = {
      color = mkTuple [ 1.0 1.0 1.0 1.0 ];
      color-axis-labels = mkTuple [ 1.0 1.0 1.0 1.0 ];
      show = false;
    };

    "com/github/wwmm/easyeffects/streaminputs" = {
      input-device = "alsa_input.pci-0000_04_00.6.analog-stereo";
    };

    "com/github/wwmm/easyeffects/streamoutputs" = {
      output-device = "alsa_output.pci-0000_04_00.6.analog-stereo";
      plugins = [ "equalizer#0" "crossfeed#0" ];
    };

    "com/github/wwmm/easyeffects/streamoutputs/crossfeed/0" = {
      fcut = 700;
      feed = 4.5;
    };

    "com/github/wwmm/easyeffects/streamoutputs/equalizer/0" = {
      input-gain = -9.99;
      num-bands = 10;
    };

    "com/github/wwmm/easyeffects/streamoutputs/equalizer/0/leftchannel" = {
      band0-frequency = 29.952623149688797;
      band0-gain = 12.5;
      band0-mode = "APO (DR)";
      band0-q = 1.504760237537245;
      band0-type = "Lo-shelf";
      band1-frequency = 59.763340205038524;
      band1-gain = -7.0;
      band1-mode = "APO (DR)";
      band1-q = 1.5047602375372453;
      band1-type = "Bell";
      band10-type = "Off";
      band11-type = "Off";
      band12-type = "Off";
      band13-type = "Off";
      band14-type = "Off";
      band15-type = "Off";
      band16-type = "Off";
      band17-type = "Off";
      band18-type = "Off";
      band19-type = "Off";
      band2-frequency = 119.24354052777788;
      band2-gain = -2.0999999046325684;
      band2-mode = "APO (DR)";
      band2-q = 1.504760237537245;
      band2-type = "Bell";
      band20-type = "Off";
      band21-type = "Off";
      band22-type = "Off";
      band23-type = "Off";
      band24-type = "Off";
      band25-type = "Off";
      band26-type = "Off";
      band27-type = "Off";
      band28-type = "Off";
      band29-type = "Off";
      band3-frequency = 237.92214271853953;
      band3-gain = 0.30000001192092896;
      band3-mode = "APO (DR)";
      band3-q = 1.504760237537245;
      band3-type = "Bell";
      band30-type = "Off";
      band31-type = "Off";
      band4-frequency = 474.71708526294935;
      band4-gain = -0.5;
      band4-mode = "APO (DR)";
      band4-q = 1.5047602375372453;
      band4-type = "Bell";
      band5-frequency = 947.1851104970312;
      band5-gain = 0.6000000238418579;
      band5-mode = "APO (DR)";
      band5-q = 1.504760237537245;
      band5-type = "Bell";
      band6-frequency = 1889.8827562743609;
      band6-gain = -1.2999999523162842;
      band6-mode = "APO (DR)";
      band6-q = 1.5047602375372449;
      band6-type = "Bell";
      band7-frequency = 3770.811843303749;
      band7-gain = 0.800000011920929;
      band7-mode = "APO (DR)";
      band7-q = 1.5047602375372449;
      band7-type = "Bell";
      band8-frequency = 7523.758767782307;
      band8-gain = 6.199999809265137;
      band8-mode = "APO (DR)";
      band8-q = 1.5047602375372453;
      band8-type = "Bell";
      band9-frequency = 15011.87233627273;
      band9-gain = -2.700000047683716;
      band9-mode = "APO (DR)";
      band9-q = 1.504760237537245;
      band9-type = "Hi-shelf";
    };

    "com/github/wwmm/easyeffects/streamoutputs/equalizer/0/rightchannel" = {
      band0-frequency = 29.952623149688797;
      band0-gain = 12.5;
      band0-mode = "APO (DR)";
      band0-mute = false;
      band0-q = 1.504760237537245;
      band0-slope = "x1";
      band0-solo = false;
      band0-type = "Lo-shelf";
      band1-frequency = 59.763340205038524;
      band1-gain = -7.0;
      band1-mode = "APO (DR)";
      band1-mute = false;
      band1-q = 1.5047602375372453;
      band1-slope = "x1";
      band1-solo = false;
      band1-type = "Bell";
      band10-frequency = 194.06;
      band10-gain = 0.0;
      band10-mode = "RLC (BT)";
      band10-mute = false;
      band10-q = 4.36;
      band10-slope = "x1";
      band10-solo = false;
      band10-type = "Off";
      band10-width = 4.0;
      band11-frequency = 240.81;
      band11-gain = 0.0;
      band11-mode = "RLC (BT)";
      band11-mute = false;
      band11-q = 4.36;
      band11-slope = "x1";
      band11-solo = false;
      band11-type = "Off";
      band11-width = 4.0;
      band12-frequency = 298.834;
      band12-gain = 0.0;
      band12-mode = "RLC (BT)";
      band12-mute = false;
      band12-q = 4.36;
      band12-slope = "x1";
      band12-solo = false;
      band12-type = "Off";
      band12-width = 4.0;
      band13-frequency = 370.834;
      band13-gain = 0.0;
      band13-mode = "RLC (BT)";
      band13-mute = false;
      band13-q = 4.36;
      band13-slope = "x1";
      band13-solo = false;
      band13-type = "Off";
      band13-width = 4.0;
      band14-frequency = 460.182;
      band14-gain = 0.0;
      band14-mode = "RLC (BT)";
      band14-mute = false;
      band14-q = 4.36;
      band14-slope = "x1";
      band14-solo = false;
      band14-type = "Off";
      band14-width = 4.0;
      band15-frequency = 571.057;
      band15-gain = 0.0;
      band15-mode = "RLC (BT)";
      band15-mute = false;
      band15-q = 4.36;
      band15-slope = "x1";
      band15-solo = false;
      band15-type = "Off";
      band15-width = 4.0;
      band16-frequency = 708.647;
      band16-gain = 0.0;
      band16-mode = "RLC (BT)";
      band16-mute = false;
      band16-q = 4.36;
      band16-slope = "x1";
      band16-solo = false;
      band16-type = "Off";
      band16-width = 4.0;
      band17-frequency = 879.387;
      band17-gain = 0.0;
      band17-mode = "RLC (BT)";
      band17-mute = false;
      band17-q = 4.36;
      band17-slope = "x1";
      band17-solo = false;
      band17-type = "Off";
      band17-width = 4.0;
      band18-frequency = 1091.26;
      band18-gain = 0.0;
      band18-mode = "RLC (BT)";
      band18-mute = false;
      band18-q = 4.36;
      band18-slope = "x1";
      band18-solo = false;
      band18-type = "Off";
      band18-width = 4.0;
      band19-frequency = 1354.19;
      band19-gain = 0.0;
      band19-mode = "RLC (BT)";
      band19-mute = false;
      band19-q = 4.36;
      band19-slope = "x1";
      band19-solo = false;
      band19-type = "Off";
      band19-width = 4.0;
      band2-frequency = 119.24354052777788;
      band2-gain = -2.0999999046325684;
      band2-mode = "APO (DR)";
      band2-mute = false;
      band2-q = 1.504760237537245;
      band2-slope = "x1";
      band2-solo = false;
      band2-type = "Bell";
      band20-frequency = 1680.47;
      band20-gain = 0.0;
      band20-mode = "RLC (BT)";
      band20-mute = false;
      band20-q = 4.36;
      band20-slope = "x1";
      band20-solo = false;
      band20-type = "Off";
      band20-width = 4.0;
      band21-frequency = 2085.35;
      band21-gain = 0.0;
      band21-mode = "RLC (BT)";
      band21-mute = false;
      band21-q = 4.36;
      band21-slope = "x1";
      band21-solo = false;
      band21-type = "Off";
      band21-width = 4.0;
      band22-frequency = 2587.79;
      band22-gain = 0.0;
      band22-mode = "RLC (BT)";
      band22-mute = false;
      band22-q = 4.36;
      band22-slope = "x1";
      band22-solo = false;
      band22-type = "Off";
      band22-width = 4.0;
      band23-frequency = 3211.29;
      band23-gain = 0.0;
      band23-mode = "RLC (BT)";
      band23-mute = false;
      band23-q = 4.36;
      band23-slope = "x1";
      band23-solo = false;
      band23-type = "Off";
      band23-width = 4.0;
      band24-frequency = 3985.01;
      band24-gain = 0.0;
      band24-mode = "RLC (BT)";
      band24-mute = false;
      band24-q = 4.36;
      band24-slope = "x1";
      band24-solo = false;
      band24-type = "Off";
      band24-width = 4.0;
      band25-frequency = 4945.15;
      band25-gain = 0.0;
      band25-mode = "RLC (BT)";
      band25-mute = false;
      band25-q = 4.36;
      band25-slope = "x1";
      band25-solo = false;
      band25-type = "Off";
      band25-width = 4.0;
      band26-frequency = 6136.63;
      band26-gain = 0.0;
      band26-mode = "RLC (BT)";
      band26-mute = false;
      band26-q = 4.36;
      band26-slope = "x1";
      band26-solo = false;
      band26-type = "Off";
      band26-width = 4.0;
      band27-frequency = 7615.17;
      band27-gain = 0.0;
      band27-mode = "RLC (BT)";
      band27-mute = false;
      band27-q = 4.36;
      band27-slope = "x1";
      band27-solo = false;
      band27-type = "Off";
      band27-width = 4.0;
      band28-frequency = 9449.96;
      band28-gain = 0.0;
      band28-mode = "RLC (BT)";
      band28-mute = false;
      band28-q = 4.36;
      band28-slope = "x1";
      band28-solo = false;
      band28-type = "Off";
      band28-width = 4.0;
      band29-frequency = 11726.8;
      band29-gain = 0.0;
      band29-mode = "RLC (BT)";
      band29-mute = false;
      band29-q = 4.36;
      band29-slope = "x1";
      band29-solo = false;
      band29-type = "Off";
      band29-width = 4.0;
      band3-frequency = 237.92214271853953;
      band3-gain = 0.30000001192092896;
      band3-mode = "APO (DR)";
      band3-mute = false;
      band3-q = 1.504760237537245;
      band3-slope = "x1";
      band3-solo = false;
      band3-type = "Bell";
      band30-frequency = 14552.2;
      band30-gain = 0.0;
      band30-mode = "RLC (BT)";
      band30-mute = false;
      band30-q = 4.36;
      band30-slope = "x1";
      band30-solo = false;
      band30-type = "Off";
      band30-width = 4.0;
      band31-frequency = 18058.4;
      band31-gain = 0.0;
      band31-mode = "RLC (BT)";
      band31-mute = false;
      band31-q = 4.36;
      band31-slope = "x1";
      band31-solo = false;
      band31-type = "Off";
      band31-width = 4.0;
      band4-frequency = 474.71708526294935;
      band4-gain = -0.5;
      band4-mode = "APO (DR)";
      band4-mute = false;
      band4-q = 1.5047602375372453;
      band4-slope = "x1";
      band4-solo = false;
      band4-type = "Bell";
      band5-frequency = 947.1851104970312;
      band5-gain = 0.6000000238418579;
      band5-mode = "APO (DR)";
      band5-mute = false;
      band5-q = 1.504760237537245;
      band5-slope = "x1";
      band5-solo = false;
      band5-type = "Bell";
      band6-frequency = 1889.8827562743609;
      band6-gain = -1.2999999523162842;
      band6-mode = "APO (DR)";
      band6-mute = false;
      band6-q = 1.5047602375372449;
      band6-slope = "x1";
      band6-solo = false;
      band6-type = "Bell";
      band7-frequency = 3770.811843303749;
      band7-gain = 0.800000011920929;
      band7-mode = "APO (DR)";
      band7-mute = false;
      band7-q = 1.5047602375372449;
      band7-slope = "x1";
      band7-solo = false;
      band7-type = "Bell";
      band8-frequency = 7523.758767782307;
      band8-gain = 6.199999809265137;
      band8-mode = "APO (DR)";
      band8-mute = false;
      band8-q = 1.5047602375372453;
      band8-slope = "x1";
      band8-solo = false;
      band8-type = "Bell";
      band9-frequency = 15011.87233627273;
      band9-gain = -2.700000047683716;
      band9-mode = "APO (DR)";
      band9-mute = false;
      band9-q = 1.504760237537245;
      band9-slope = "x1";
      band9-solo = false;
      band9-type = "Hi-shelf";
    };

    "com/github/wwmm/easyeffects/streamoutputs/reverb/0" = {
      bypass = true;
    };

    "it/mijorus/smile" = {
      last-run-version = "2.11.0";
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
      font-name = "Comic Neue Regular 12";
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

    "org/gnome/nm-applet/eap/077f9e17-ac53-42f4-bc92-73299011a276" = {
      ignore-ca-cert = false;
      ignore-phase2-ca-cert = false;
    };

    "org/gnome/nm-applet/eap/1fd08d79-3b75-4bb4-8171-0a163d16300d" = {
      ignore-ca-cert = false;
      ignore-phase2-ca-cert = false;
    };

    "org/gnome/nm-applet/eap/322fc470-0282-43d3-bb75-958331a0f27a" = {
      ignore-ca-cert = false;
      ignore-phase2-ca-cert = false;
    };

    "org/gnome/nm-applet/eap/811c4ed9-429a-4c7b-bc0b-a77772ad9f15" = {
      ignore-ca-cert = false;
      ignore-phase2-ca-cert = false;
    };

    "org/gnome/nm-applet/eap/adc15f0e-9fc6-46c2-8c74-4b8468e20107" = {
      ignore-ca-cert = false;
      ignore-phase2-ca-cert = false;
    };

    "org/gnome/nm-applet/eap/d062764a-a696-47e8-865b-843023a21a53" = {
      ignore-ca-cert = false;
      ignore-phase2-ca-cert = false;
    };

    "org/gnome/nm-applet/eap/fbca9679-39ce-425c-920f-436162f91cf8" = {
      ignore-ca-cert = false;
      ignore-phase2-ca-cert = false;
    };

    "org/gtk/gtk4/settings/color-chooser" = {
      custom-colors = [ (mkTuple [ 0.784314 0.145098 0.721569 1.0 ]) ];
      selected-color = mkTuple [ true 1.0 0.470588 0.0 1.0 ];
    };

    "org/gtk/gtk4/settings/file-chooser" = {
      date-format = "regular";
      location-mode = "path-bar";
      show-hidden = false;
      sidebar-width = 140;
      sort-column = "name";
      sort-directories-first = true;
      sort-order = "ascending";
      type-format = "category";
      view-type = "list";
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
