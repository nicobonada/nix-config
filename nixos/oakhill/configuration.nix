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

  nixpkgs.config.allowUnfree = true;

  networking = {
    hostName = "oakhill";
    networkmanager.enable = true;
  };

  time.timeZone = "America/Toronto";

  services.logind.settings.Login.HandlePowerKey = "suspend";

  hardware = {
    graphics.enable32Bit = true;
    logitech.wireless = {
      enable = true;
      enableGraphical = true;
    };
    opentabletdriver.enable = true;
  };

  environment.systemPackages = with pkgs; [
    lm_sensors
  ];

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "22.05";
}
