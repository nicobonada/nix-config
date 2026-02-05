{ config, pkgs, lib, ... }:
let
  cfg = config.gaming;
in {
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

    services.flatpak.enable = true;   # for Hytale

    environment.systemPackages = with pkgs; [
      dualsensectl
      protonup-rs
      gamescope-wsi # HDR won't work without this
    ];
  };
}

