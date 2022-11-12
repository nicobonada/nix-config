{
  services.mpd = {
    enable = true;
    network.listenAddress = "any";
    extraConfig = ''
      zeroconf_enabled "yes"

      audio_output {
        type "pipewire"
        name "Pipewire Sound Server"
      }

      replaygain "album"
      replaygain_preamp "0"
      replaygain_missing_preamp "-6"
    '';
  };
}
