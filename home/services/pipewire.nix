{
  services.pipewire = {
    enable = true;
    # Firefox -> SoundCore mini (F4:2B:7D:63:60:B4) when that
    # sink exists.
    pulseConfigs."50-firefox-soundcore" = {
      "pulse.rules" = [
        {
          matches = [
            { "application.process.binary" = "firefox"; }
            { "application.process.binary" = ".firefox-wrapped"; }
          ];
          actions = {
            quirks = [ "remove-capture-dont-move" ];
            update-props = {
              "target.object" = "bluez_output.F4_2B_7D_63_60_B4.1";
              "node.dont-move" = true;
            };
          };
        }
      ];
    };
  };
}
