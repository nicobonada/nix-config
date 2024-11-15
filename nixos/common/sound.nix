{ pkgs, ... }:
{
  hardware.bluetooth.enable = true;
  services.blueman.enable = true;

  security.rtkit.enable = true;

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    # jack.enable = true;
  };

  environment.systemPackages = with pkgs; [
    alsa-utils
    pavucontrol
    pulsemixer
  ];
}
