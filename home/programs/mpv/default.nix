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
  };
}
