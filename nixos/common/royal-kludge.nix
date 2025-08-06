{ config, pkgs, lib, ... }:
let
  cfg = config.royal-kludge;
in {
  options.royal-kludge = {
    enable = lib.mkEnableOption "royal-kludge";
  };

  config = lib.mkIf cfg.enable {
    hardware.keyboard.qmk.enable = true;

    services.udev.extraRules = ''
    # Royal Kludge R87 Pro - prevent joystick classification (it's a keyboard)
    SUBSYSTEM=="input", ATTRS{idVendor}=="342d", ATTRS{idProduct}=="e48e", ENV{ID_INPUT_JOYSTICK}="0"

    # Royal Kludge R65 - prevent joystick classification
    SUBSYSTEM=="input", ATTRS{idVendor}=="342d", ATTRS{idProduct}=="e508", ENV{ID_INPUT_JOYSTICK}="0"
    '';

    environment.systemPackages = [ pkgs.via ];
  };
}
