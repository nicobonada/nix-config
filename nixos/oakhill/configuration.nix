{ inputs, lib, config, pkgs, ... }: {
  imports = [
    ./boot.nix
    ../common
    ./hardware-configuration.nix
  ];

  amd-cpu.enable = true;
  amd-gpu.enable = true;
  # container.enable = true;
  gaming.enable = true;
  royal-kludge.enable = true;

  networking.hostName = "oakhill";

  hardware = {
    graphics.enable32Bit = true;
    # udev + ltunify. Solaar GUI is programs.solaar (user service, any compositor).
    logitech.wireless.enable = true;
    opentabletdriver.enable = true;
  };

  programs.solaar = {
    enable = true;
    userService.enable = true; # graphical-session; window hidden, tray only
  };

  environment.systemPackages = with pkgs; [
    lm_sensors
  ];

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "22.05";
}
