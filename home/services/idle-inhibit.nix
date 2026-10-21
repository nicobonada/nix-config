{ inputs, ... }:
{
  imports = [ inputs.wayland-pipewire-idle-inhibit.homeModules.default ];

  # Skip the EQ playback streams. name matches the Helvum
  # description, which the sink shares, so media_class keeps the
  # sink eligible. Descriptions live in home/services/pipewire.nix.
  #
  # The module's unit is Restart=always and has no PartOf. Without
  # PartOf it would keep restarting after logout.
  services.wayland-pipewire-idle-inhibit = {
    enable = true;
    settings = {
      verbosity = "WARN";
      media_minimum_duration = 5;
      idle_inhibitor = "wayland";
      node_blacklist = [
        {
          name = "^(HyperX Cloud Alpha Wireless EQ|HD 6XX EQ|Jabra Elite 10 EQ)$";
          media_class = "^Stream/Output/Audio$";
        }
      ];
    };
  };

  systemd.user.services.wayland-pipewire-idle-inhibit.Unit.PartOf = [
    "graphical-session.target"
  ];
}
