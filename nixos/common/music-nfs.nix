{ ... }:
let
  # Short name is MagicDNS / Technitium. Do not put Tailscale IPs or
  # *.ts.net in this public flake.
  # pve exports the T7 ext4 directly. Homelab still has the virtiofs
  # tree for Samba / restic; do not mount that reexport.
  server = "pve";
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
    device = "${server}:/mnt/backup/music";
    fsType = "nfs";
    options = nfsCommon;
  };

  fileSystems."/home/nico/.local/share/beets-state" = {
    device = "${server}:/mnt/backup/beets-state";
    fsType = "nfs";
    options = nfsCommon;
  };
}
