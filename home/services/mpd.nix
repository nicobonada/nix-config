{ config, pkgs, lib, ... }:
{
  services = {
    mpd = {
      enable = true;
      network.listenAddress = "any";
      enableSessionVariables = false;   # MPD_HOST doesn't support "any"

      extraConfig = ''
        zeroconf_enabled "yes"

        audio_output {
          type "pipewire"
          name "Pipewire Sound Server"
        }

        replaygain "album"
        replaygain_preamp "0"
        replaygain_missing_preamp "-6"
      '';
    };

    mpd-mpris = {
      enable = true;
      mpd.useLocal = true;
    };
  };

  programs.ncmpcpp = {
    enable = true;
    settings = {
      progressbar_look = "->-";
      user_interface = "alternative";
      space_add_mode = "always_add";
      external_editor = "nvim";
      browser_display_mode = "columns";
    };
  };

  home.packages = with pkgs; [
    mpc
    mpd-notification
  ];

  xdg.configFile."mpd-notification.conf".text = ''
    music-dir = ${config.services.mpd.musicDirectory}
  '';

  systemd.user.services.mpd-notification = {
    Unit = {
      Description = "MPD Notification";
      Requires = "dbus.socket";
      PartOf= "graphical-session.target";
      After = [
        "mpd.service"
        "network.target"
        "network-online.target"
        "graphical-session.target"
        "swaync.service"
      ];
    };

    Service = {
      Type = "notify";
      Restart = "on-failure";
      ExecStart="${lib.getExe pkgs.mpd-notification}";
    };

    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
  };
}
