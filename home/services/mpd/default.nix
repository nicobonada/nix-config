{
  services = {
    mpd = {
      enable = true;
      network.listenAddress = "any";
      extraConfig = builtins.readFile ./mpd.conf;
    };

    mpd-mpris = {
      enable = true;
      mpd.useLocal = true;
    };
  };
}
