{ pkgs, ... }:
{
  security.pam.u2f = {
    enable = true;
    cue = true;
  };

  services = {
    udev.packages = [ pkgs.yubikey-personalization ];
    pcscd.enable = true;
  };
}
