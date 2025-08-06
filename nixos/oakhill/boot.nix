{ config, lib, pkgs, ... }:
{
  boot = {
    loader = {
      # Use the systemd-boot EFI boot loader.
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
    kernelModules = [ "nct6775" ];         # from lm_sensors
    kernelParams = [
      "nohibernate"      # zfs doesn't support hibernate

      "zswap.enabled=1"           # enables zswap
      "zswap.shrinker_enabled=1"  # whether to shrink the pool proactively on high memory pressure
    ];
    initrd.kernelModules = [ "amdgpu" ];

    supportedFilesystems = [ "zfs" ];
    initrd.supportedFilesystems = ["zfs"]; # boot from zfs

    kernelPackages = pkgs.linuxPackages_zen;
    zfs.package = pkgs.zfs_2_4;
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
