{ config, pkgs, lib, ... }:
let
  cfg = config.royal-kludge;
in {
  options.royal-kludge = {
    enable = lib.mkEnableOption "royal-kludge";
  };

  config = lib.mkIf cfg.enable {
    # VIA/hidraw access. Keymap dumps + via-r87 CLI: keyboards/r87pro/
    hardware.keyboard.qmk.enable = true;

    services.udev.extraRules = /* udev */ ''
    # Royal Kludge R87 Pro - prevent joystick classification (it's a keyboard)
    SUBSYSTEM=="input", ATTRS{idVendor}=="342d", ATTRS{idProduct}=="e48e", ENV{ID_INPUT_JOYSTICK}="0"

    # Royal Kludge R65 - prevent joystick classification
    SUBSYSTEM=="input", ATTRS{idVendor}=="342d", ATTRS{idProduct}=="e508", ENV{ID_INPUT_JOYSTICK}="0"
    '';

    environment.systemPackages = [ pkgs.via ];
  };
}
