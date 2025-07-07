{ pkgs, ... }:
{
  hardware.steam-hardware.enable = true;
  programs.steam.enable = true;

  programs.gamemode.enable = true;
  users.extraUsers.nico.extraGroups = [ "gamemode" ];

  environment.systemPackages = with pkgs; [
    dualsensectl
    mangohud
    prismlauncher
    protonup-qt
  ];

  # Treat 8bitdo ultimate controller as xbox controller
 services.udev.extraRules = /*udev*/''
   ACTION=="add", ATTRS{idVendor}=="2dc8", ATTRS{idProduct}=="3109", RUN+="/sbin/modprobe xpad", RUN+="/bin/sh -c 'echo 2dc8 3109 > /sys/bus/usb/drivers/xpad/new_id'"
 '';
}

