{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.gaming;
in
{
  options.gaming = {
    enable = lib.mkEnableOption "gaming";
  };

  config = lib.mkIf cfg.enable {
    hardware.steam-hardware.enable = true;
    programs.steam.enable = true;

    programs.gamemode.enable = true;
    users.extraUsers.nico.extraGroups = [ "gamemode" ];

    programs.gamescope = {
      enable = true;
      capSysNice = false;
    };

    services.flatpak.enable = true; # for Hytale

    # Raiju V3 Pro clickable touch surface enumerates as an external
    # libinput touchpad and steals pointer/gestures from niri.
    # PIDs: 1024 wired, 1026 PS/Wireless dongle, 1027 PC wireless.
    services.udev.extraRules = /* udev */ ''
      ACTION=="add|change", SUBSYSTEM=="input", KERNEL=="event*", ATTRS{idVendor}=="1532", ATTRS{idProduct}=="1024|1026|1027", ENV{ID_INPUT_TOUCHPAD}=="1", ENV{LIBINPUT_IGNORE_DEVICE}="1"
    '';

    environment.systemPackages = with pkgs; [
      dualsensectl
      protonup-rs

      pulseaudio # steam seems to rely on pactl being available
    ];
  };
}
