{ pkgs, ... }:
{
  security.pam.u2f = {
    enable = true;
    settings.cue = true;
  };

  services = {
    udev.packages = [ pkgs.yubikey-personalization ];
    pcscd.enable = true;
  };

  environment.systemPackages = with pkgs; [
    yubikey-manager
    yubioath-flutter
  ];
}
