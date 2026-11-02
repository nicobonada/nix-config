{ ... }:
let
  # Short name is MagicDNS / Technitium. Do not put Tailscale IPs or
  # *.ts.net in this public flake.
  server = "homelab";
  nfsCommon = [
    "nfsvers=4.2"
    "_netdev"
    "noauto"
    "x-systemd.automount"
    "x-systemd.mount-timeout=30s"
    "x-systemd.idle-timeout=10min"
    "x-systemd.after=tailscaled.service"
    "x-systemd.requires=tailscaled.service"
    "hard"
  ];
in
{
  # Hide any local tree before switching this host:
  #   mv ~/music ~/music.local
  #   mv ~/.local/share/beets-state ~/.local/share/beets-state.local
  boot.supportedFilesystems.nfs = true;

  fileSystems."/home/nico/music" = {
    device = "${server}:/mnt/pve-backup/music";
    fsType = "nfs";
    options = nfsCommon;
  };

  fileSystems."/home/nico/.local/share/beets-state" = {
    device = "${server}:/mnt/pve-backup/beets-state";
    fsType = "nfs";
    options = nfsCommon;
  };
}
