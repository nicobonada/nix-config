{ config, pkgs, lib, ... }:
{
  services = {
    mpd = {
      enable = true;
      network.listenAddress = "any";
      extraConfig = builtins.readFile ./mpd.conf;
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
    mpc_cli
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
