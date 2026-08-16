{ pkgs, ... }:
{
  programs = {
    mpv = {
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
        "Alt+=" = "add video-zoom 0.1"; # zoom in
        "ctrl+=" = "add audio-delay 0.100"; # change audio/video sync by delaying the audio
      };

      scripts = with pkgs.mpvScripts; [
        #uosc
        modernz
        thumbfast
      ];
    };

    obs-studio = {
      enable = true;

      plugins = with pkgs.obs-studio-plugins; [
        wlrobs
        obs-backgroundremoval
        obs-pipewire-audio-capture
        obs-vaapi # optional AMD hardware acceleration
        obs-gstreamer
        obs-vkcapture
      ];
    };

    yt-dlp.enable = true;
  };

  home.packages = with pkgs; [
    beets
    cavalier
    gallery-dl
    kid3
    mediainfo
    nicotine-plus
    playerctl
    qbittorrent
    r128gain
  ];

  xdg.configFile."beets/config.yaml".source = ../configs/beets_config.yaml;

}
