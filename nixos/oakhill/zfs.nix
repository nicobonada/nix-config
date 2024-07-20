{ pkgs, ... }:
{
  boot = {
    supportedFilesystems = [ "zfs" ];
    initrd.supportedFilesystems = ["zfs"]; # boot from zfs
    zfs.package = pkgs.zfs_unstable;
  };

  networking.hostId = "23c95f57";

  services = {
    zfs = {
      autoScrub.enable = true;
      trim.enable = true;
    };

    # zfs already has its own scheduler. without this my(@Artturin) computer froze for a second when i nix build something.
    udev.extraRules = /*udev*/''
      ACTION=="add|change", KERNEL=="sd[a-z]*[0-9]*|mmcblk[0-9]*p[0-9]*|nvme[0-9]*n[0-9]*p[0-9]*", ENV{ID_FS_TYPE}=="zfs_member", ATTR{../queue/scheduler}="none"
    '';
  };
}
