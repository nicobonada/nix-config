{ pkgs, ... }:
{
  programs.mpv = {
    enable = true;
    config = {
      profile = "gpu-hq";
      video-sync = "display-resample";
      interpolation = "";
      no-hidpi-window-scale = "";

      audio-display = false;
      term-osd-bar = true;
      term-osd-bar-chars = "[=>-]";
    };

    bindings = {
      "Alt+="  = "add video-zoom 0.1";    # zoom in
      "ctrl+=" = "add audio-delay 0.100"; # change audio/video sync by delaying the audio
    };

    scripts = with pkgs.mpvScripts; [ uosc thumbfast ];
  };
}
