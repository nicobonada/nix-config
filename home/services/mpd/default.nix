{
  services.mpd = {
    enable = true;
    network.listenAddress = "any";
    extraConfig = builtins.readFile ./mpd.conf;
  };
}
