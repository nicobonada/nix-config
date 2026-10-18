{ inputs, ... }:
{
  imports = [ inputs.wayland-pipewire-idle-inhibit.homeModules.default ];

  # The inhibitor follows PipeWire links, not audible sound. Each
  # eq-*-playback node has no inputs, and wiremix keeps that link
  # up, so those nodes look like players. Skip them. A real player
  # attaches to eq-<name>, the sink WirePlumber inserts ahead of
  # the hardware, which is not matched here. Five seconds ignores
  # notification blips.
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
        { name = "^eq-.*-playback$"; }
      ];
    };
  };

  systemd.user.services.wayland-pipewire-idle-inhibit.Unit.PartOf = [
    "graphical-session.target"
  ];
}
