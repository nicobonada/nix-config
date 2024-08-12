{ pkgs, ... }:
{
  security.rtkit.enable = true;

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    # jack.enable = true;

    # without the following lines pipewire keeps the camera open, drawing
    # significant amounts of power on laptops
    # https://gitlab.freedesktop.org/pipewire/pipewire/-/issues/2669#note_2362342
    wireplumber = {
      extraConfig = {
        "10-disable-camera" = {
          "wireplumber.profiles" = {
            main."monitor.libcamera" = "disabled";
          };
        };
      };
    };
  };

  environment.systemPackages = with pkgs; [
    alsa-utils
    pavucontrol
    pulsemixer
  ];
}
