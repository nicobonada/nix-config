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

    extraConfig = {
      pipewire."92-low-latency" = {
        "context.properties" = {
          # Default sample rate
          "default.clock.rate" = 48000;
          # Lower values mean lower latency, but higher CPU usage
          "default.clock.quantum" = 256;
          "default.clock.min-quantum" = 256;
          "default.clock.max-quantum" = 256;
          # Buffer configuration
          "link.max-buffers" = 64;
        };
      };

      # Configure PulseAudio-specific settings
      pipewire-pulse."92-low-latency" = {
        "stream.properties" = {
          "node.latency" = "256/48000";
          "resample.quality" = 1;
        };
        "context.modules" = [
          {
            name = "libpipewire-module-protocol-pulse";
            args = {
              "pulse.min.req" = "256/48000";
              "pulse.default.req" = "256/48000";
              "pulse.max.req" = "256/48000";
              "pulse.min.quantum" = "256/48000";
              "pulse.max.quantum" = "256/48000";
            };
          }
        ];
      };
    };

    wireplumber.extraConfig."51-disable-suspend" = {
      "session.suspend-timeout-seconds" = 0;
    };
  };

  environment.etc."modprobe.d/audio-disable-powersave.conf" = {
    text = ''
      options snd_hda_intel power_save=0
    '';
  };

  environment.systemPackages = with pkgs; [
    alsa-utils
    pavucontrol
    pulsemixer
  ];
}
